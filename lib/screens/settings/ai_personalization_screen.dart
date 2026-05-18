import 'dart:convert';

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/prompt_item.dart';
import '../../services/settings_manager.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../theme/app_icons.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_prompts.dart';
import '../models/hugging_face_search_screen.dart';
import 'prompt_detail_screen.dart';

/// Preset profile IDs match iOS [AIPersonalizationViewController] UUID strings.
/// Custom prompts persist via MeData (iOS uses UserDefaults for the same logical key).
const String _presetDefaultId = '00000000-0000-0000-0000-000000000001';
const String _presetCodingId = '00000000-0000-0000-0000-000000000002';
const String _presetCreativeId = '00000000-0000-0000-0000-000000000003';
const String _presetTranslatorId = '00000000-0000-0000-0000-000000000004';

List<PromptItem> _defaultPresets() => [
      PromptItem(
        id: _presetDefaultId,
        title: 'Default',
        description: 'General purpose balanced responses',
        content: AppPrompts.systemHelpfulAssistant,
        isPreset: true,
        icon: 'checkmark.circle.fill',
      ),
      PromptItem(
        id: _presetCodingId,
        title: 'Coding',
        description: 'Optimized for technical and syntax tasks',
        content: AppPrompts.systemSoftwareEngineer,
        isPreset: true,
        icon: 'curlybraces',
      ),
      PromptItem(
        id: _presetCreativeId,
        title: 'Creative',
        description: 'Poetic, imaginative, and descriptive tone',
        content: AppPrompts.systemCreativeWriter,
        isPreset: true,
        icon: 'paintpalette.fill',
      ),
      PromptItem(
        id: _presetTranslatorId,
        title: 'Translator',
        description: 'Direct translation without extra chat',
        content: AppPrompts.systemExpertLinguist,
        isPreset: true,
        icon: 'globe',
      ),
    ];

/// AI Personalization: profiles, response style, context, Hugging Face (iOS parity).
class AIPersonalizationScreen extends StatefulWidget {
  const AIPersonalizationScreen({super.key});

  @override
  State<AIPersonalizationScreen> createState() =>
      _AIPersonalizationScreenState();
}

class _AIPersonalizationScreenState extends State<AIPersonalizationScreen> {
  List<PromptItem> _prompts = [];
  String _selectedPromptId = _presetDefaultId;
  String _currentSystemPrompt = AppPrompts.systemHelpfulAssistant;
  double _currentTemperature = 0.7;
  int _currentNCtx = 10000;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<List<PromptItem>> _loadCustomPrompts() async {
    try {
      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(
        AppConstants.personalizationKeys.customPrompts,
      );
      if (record?.values.isNotEmpty != true) return [];
      final jsonStr = record!.values.first.value.toString();
      if (jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => PromptItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCustomPrompts(List<PromptItem> custom) async {
    try {
      final meDataService = DataSapien.getMeDataService();
      final jsonStr = jsonEncode(custom.map((e) => e.toJson()).toList());
      await meDataService.saveMeDataRecord(
        AppConstants.personalizationKeys.customPrompts,
        jsonStr,
      );
    } catch (_) {}
  }

  Future<void> _loadAll() async {
    try {
      await SettingsManager.shared.loadSettings();
      final custom = await _loadCustomPrompts();
      var list = [..._defaultPresets(), ...custom];
      final sp = SettingsManager.shared.systemPrompt;
      String? selectedId;
      for (final p in list) {
        if (p.content == sp) {
          selectedId = p.id;
          break;
        }
      }
      if (selectedId == null && sp.isNotEmpty) {
        final legacy = PromptItem(
          id: 'legacy-${sp.hashCode}',
          title: 'Custom',
          description: 'Previously used system instructions',
          content: sp,
          isPreset: false,
          icon: 'pencil',
        );
        list = [...list, legacy];
        selectedId = legacy.id;
      }
      if (!mounted) return;
      final resolvedId = selectedId ?? _presetDefaultId;
      setState(() {
        _prompts = list;
        _selectedPromptId = resolvedId;
        _currentSystemPrompt = sp.isNotEmpty
            ? sp
            : list.firstWhere((p) => p.id == resolvedId).content;
        _currentTemperature = SettingsManager.shared.temperature;
        _currentNCtx = _snapNCtx(SettingsManager.shared.nCtx);
      });
    } catch (e, st) {
      debugPrint('AIPersonalization _loadAll: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Nearest multiple of 1024 in [1024, 32768] (matches iOS slider snapping).
  int _snapNCtx(int n) {
    final clamped = n.clamp(1024, 32768);
    return ((clamped / 1024).round() * 1024).clamp(1024, 32768);
  }

  int _nCtxFromSliderIndex(int i) {
    return 1024 * (i.clamp(0, 31) + 1);
  }

  int _sliderIndexFromNCtx(int n) {
    final snapped = _snapNCtx(n);
    return (snapped ~/ 1024) - 1;
  }

  String _styleBadgeLabel(AppLocalizations l10n) {
    if (_currentTemperature < 0.4) return l10n.settings_style_concise;
    if (_currentTemperature < 0.7) return l10n.settings_style_balanced;
    return l10n.settings_style_detailed;
  }

  String _formattedTemperature() {
    return _currentTemperature.clamp(0.0, 1.0).toStringAsFixed(1);
  }

  void _selectPrompt(PromptItem p) {
    setState(() {
      _selectedPromptId = p.id;
      _currentSystemPrompt = p.content;
    });
  }

  Future<void> _openDetail(PromptItem? prompt, {required bool readOnly}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PromptDetailScreen(
          prompt: prompt,
          readOnly: readOnly,
          onSave: (saved) {
            setState(() {
              final idx = _prompts.indexWhere((p) => p.id == saved.id);
              if (idx >= 0) {
                _prompts = [..._prompts]..[idx] = saved;
              } else {
                _prompts = [..._prompts, saved];
              }
              _selectedPromptId = saved.id;
              _currentSystemPrompt = saved.content;
            });
            _saveCustomPrompts(
              _prompts.where((p) => !p.isPreset).toList(),
            );
          },
          onDelete: (id) {
            setState(() {
              _prompts = _prompts.where((p) => p.id != id).toList();
              if (_selectedPromptId == id) {
                _selectedPromptId = _presetDefaultId;
                _currentSystemPrompt = _prompts
                    .firstWhere((p) => p.id == _presetDefaultId)
                    .content;
              }
            });
            _saveCustomPrompts(
              _prompts.where((p) => !p.isPreset).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveAndPop() async {
    final persistedSnap = _snapNCtx(SettingsManager.shared.nCtx);
    final nCtxChanged = _currentNCtx != persistedSnap;
    SettingsManager.shared.systemPrompt = _currentSystemPrompt;
    SettingsManager.shared.temperature = _currentTemperature;
    SettingsManager.shared.nCtx = _currentNCtx;
    setState(() => _saving = true);
    await SettingsManager.shared.saveSettings();
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(nCtxChanged);
    }
  }

  Widget _sectionDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color: AppColor.textSecondary(context).withValues(alpha: 0.08),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor.secondaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: AppColor.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          l10n.settings_ai_personalization,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: (_loading || _saving) ? null : _saveAndPop,
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryTint,
                foregroundColor: AppColor.buttonText,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.settings_ai_save),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  l10n.settings_prompt_profiles,
                  style: AppFont.captionBold.copyWith(
                    fontSize: 13,
                    color: AppColor.textSecondary(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ..._prompts.map((p) => _buildPromptCard(context, p)),
                const SizedBox(height: 12),
                _DashedAddPromptButton(
                  label: l10n.settings_add_custom_prompt,
                  onTap: () => _openDetail(null, readOnly: false),
                ),
                _sectionDivider(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.settings_response_style,
                      style: AppFont.captionBold.copyWith(
                        fontSize: 13,
                        color: AppColor.textSecondary(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryTint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_styleBadgeLabel(l10n)} · temperature: ${_formattedTemperature()}',
                        style: AppFont.captionBold.copyWith(
                          fontSize: 11,
                          color: AppColor.primaryTint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColor.primaryTint,
                    inactiveTrackColor:
                        AppColor.textSecondary(context).withValues(alpha: 0.15),
                    thumbColor: AppColor.primaryTint,
                    overlayColor: AppColor.primaryTint.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: _currentTemperature.clamp(0.0, 1.0),
                    min: 0,
                    max: 1,
                    onChanged: (v) =>
                        setState(() => _currentTemperature = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.settings_style_footer_concise,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textSecondary(context)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      l10n.settings_style_footer_detailed,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textSecondary(context)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                _sectionDivider(context),
                Text(
                  l10n.settings_advanced_settings,
                  style: AppFont.captionBold.copyWith(
                    fontSize: 13,
                    color: AppColor.textSecondary(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColor.primaryBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.settings_context_window,
                              style: AppFont.bodyBold.copyWith(
                                color: AppColor.textPrimary(context),
                              ),
                            ),
                            Text(
                              '$_currentNCtx',
                              style: AppFont.captionBold.copyWith(
                                color: AppColor.primaryTint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColor.primaryTint,
                            inactiveTrackColor: AppColor.textSecondary(context)
                                .withValues(alpha: 0.15),
                            thumbColor: AppColor.primaryTint,
                          ),
                          child: Slider(
                            value: _sliderIndexFromNCtx(_currentNCtx)
                                .toDouble(),
                            min: 0,
                            max: 31,
                            divisions: 31,
                            onChanged: (v) => setState(() {
                              _currentNCtx = _nCtxFromSliderIndex(v.round());
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.settings_context_window_note,
                          style: AppFont.caption.copyWith(
                            color: AppColor.textSecondary(context)
                                .withValues(alpha: 0.5),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _sectionDivider(context),
                Text(
                  l10n.settings_section_hugging_face,
                  style: AppFont.captionBold.copyWith(
                    fontSize: 13,
                    color: AppColor.textSecondary(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const HuggingFaceSearchScreen(),
                      ),
                    );
                  },
                  icon: const Icon(AppIcons.arrowDownDocumentFill, size: 18),
                  label: Text(l10n.hf_add_models_button),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColor.primaryTint,
                    foregroundColor: AppColor.buttonText,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPromptCard(BuildContext context, PromptItem p) {
    final selected = p.id == _selectedPromptId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColor.primaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColor.primaryTint.withValues(alpha: 0.5)
                  : AppColor.textSecondary(context).withValues(alpha: 0.1),
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectPrompt(p),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  p.title,
                                  style: AppFont.bodyBold.copyWith(
                                    color: AppColor.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFont.caption.copyWith(
                                    color: AppColor.textSecondary(context)
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _RadioDot(selected: selected),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(
                  AppIcons.chevronRight,
                  color: AppColor.textSecondary(context).withValues(alpha: 0.3),
                  size: 14,
                ),
                onPressed: () => _openDetail(p, readOnly: p.isPreset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColor.primaryTint
              : AppColor.textSecondary(context).withValues(alpha: 0.2),
          width: 2,
        ),
        color: selected
            ? AppColor.primaryTint.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primaryTint,
                ),
              ),
            )
          : null,
    );
  }
}

class _DashedAddPromptButton extends StatelessWidget {
  const _DashedAddPromptButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: AppColor.textSecondary(context).withValues(alpha: 0.35),
            borderRadius: 16,
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.plusCircleFill,
                  color: AppColor.textSecondary(context).withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppFont.bodyBold.copyWith(
                    color: AppColor.textPrimary(context).withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final len = (d + dash > metric.length) ? metric.length - d : dash;
        final extract = metric.extractPath(d, d + len);
        canvas.drawPath(extract, paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
