import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Pocket Models'**
  String get app_title;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Pocket Models'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Powerful AI, entirely on your device'**
  String get welcome_subtitle;

  /// No description provided for @welcome_desc1.
  ///
  /// In en, this message translates to:
  /// **'Your conversations stay private, always'**
  String get welcome_desc1;

  /// No description provided for @welcome_desc2.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions, no cloud, no compromises'**
  String get welcome_desc2;

  /// No description provided for @continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

  /// No description provided for @back_button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_button;

  /// No description provided for @features_title.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features_title;

  /// No description provided for @features_private_title.
  ///
  /// In en, this message translates to:
  /// **'100% Private'**
  String get features_private_title;

  /// No description provided for @features_private_desc.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your device. No data ever leaves your iPhone.'**
  String get features_private_desc;

  /// No description provided for @features_free_title.
  ///
  /// In en, this message translates to:
  /// **'Completely Free'**
  String get features_free_title;

  /// No description provided for @features_free_desc.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions, no hidden fees. Yours forever.'**
  String get features_free_desc;

  /// No description provided for @features_voice_title.
  ///
  /// In en, this message translates to:
  /// **'Responsive Voice Mode'**
  String get features_voice_title;

  /// No description provided for @features_voice_desc.
  ///
  /// In en, this message translates to:
  /// **'Natural conversations with lightning-fast speech recognition.'**
  String get features_voice_desc;

  /// No description provided for @features_vision_title.
  ///
  /// In en, this message translates to:
  /// **'Vision AI'**
  String get features_vision_title;

  /// No description provided for @features_vision_desc.
  ///
  /// In en, this message translates to:
  /// **'Analyze images and scenes securely, all on-device.'**
  String get features_vision_desc;

  /// No description provided for @features_docs_title.
  ///
  /// In en, this message translates to:
  /// **'Documents & Photos'**
  String get features_docs_title;

  /// No description provided for @features_docs_desc.
  ///
  /// In en, this message translates to:
  /// **'Analyze text, PDFs, and photos safely.'**
  String get features_docs_desc;

  /// No description provided for @splash_powered_by.
  ///
  /// In en, this message translates to:
  /// **'powered by DataSapien'**
  String get splash_powered_by;

  /// No description provided for @model_row_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get model_row_download;

  /// No description provided for @model_row_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get model_row_downloaded;

  /// No description provided for @model_row_queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get model_row_queued;

  /// No description provided for @features_web_title.
  ///
  /// In en, this message translates to:
  /// **'Web Search'**
  String get features_web_title;

  /// No description provided for @features_web_desc.
  ///
  /// In en, this message translates to:
  /// **'Find the latest information instantly.'**
  String get features_web_desc;

  /// No description provided for @features_memory_title.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get features_memory_title;

  /// No description provided for @features_memory_desc.
  ///
  /// In en, this message translates to:
  /// **'Remembers what\'s important across chats.'**
  String get features_memory_desc;

  /// No description provided for @features_custom_title.
  ///
  /// In en, this message translates to:
  /// **'Fully Customizable'**
  String get features_custom_title;

  /// No description provided for @features_custom_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose your AI models, themes, and personalize your experience.'**
  String get features_custom_desc;

  /// No description provided for @models_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your AI Model'**
  String get models_title;

  /// No description provided for @models_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the intelligence engine that will power your app.'**
  String get models_subtitle;

  /// No description provided for @models_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading models...'**
  String get models_loading;

  /// No description provided for @models_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load AI models.'**
  String get models_error;

  /// No description provided for @onboarding_models_empty.
  ///
  /// In en, this message translates to:
  /// **'No models are available. Try again later.'**
  String get onboarding_models_empty;

  /// No description provided for @chat_input_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_input_placeholder;

  /// No description provided for @chat_hint_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_hint_placeholder;

  /// No description provided for @chat_model_downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get chat_model_downloading;

  /// No description provided for @chat_model_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading Model...'**
  String get chat_model_loading;

  /// No description provided for @chat_model_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get chat_model_ready;

  /// No description provided for @chat_empty_heading.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get chat_empty_heading;

  /// No description provided for @chat_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message below to start chatting with your private AI. For best results, ask clear and specific questions.'**
  String get chat_empty_hint;

  /// No description provided for @chat_deleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chat_deleted;

  /// No description provided for @see_attached_document.
  ///
  /// In en, this message translates to:
  /// **'See attached document'**
  String get see_attached_document;

  /// No description provided for @attached_image_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Attached Image'**
  String get attached_image_subtitle;

  /// No description provided for @select_model.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get select_model;

  /// No description provided for @select_model_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get select_model_sheet_title;

  /// No description provided for @select_model_sheet_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading models...'**
  String get select_model_sheet_loading;

  /// No description provided for @select_model_sheet_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load models.'**
  String get select_model_sheet_error;

  /// No description provided for @model_delete_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Model'**
  String get model_delete_dialog_title;

  /// No description provided for @model_delete_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {modelName}? This will remove it from your device.'**
  String model_delete_dialog_message(String modelName);

  /// No description provided for @model_delete_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get model_delete_dialog_confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @default_model.
  ///
  /// In en, this message translates to:
  /// **'Default model'**
  String get default_model;

  /// No description provided for @new_chat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get new_chat;

  /// No description provided for @error_generic_response.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate response.'**
  String get error_generic_response;

  /// No description provided for @error_context_size.
  ///
  /// In en, this message translates to:
  /// **'Message length limit exceeded. Please start a new chat.'**
  String get error_context_size;

  /// No description provided for @error_init_context.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize the model. Please try again.'**
  String get error_init_context;

  /// No description provided for @error_decoding.
  ///
  /// In en, this message translates to:
  /// **'Could not decode the model\'s response.'**
  String get error_decoding;

  /// No description provided for @error_empty_message.
  ///
  /// In en, this message translates to:
  /// **'No message to send was found.'**
  String get error_empty_message;

  /// No description provided for @error_file_not_found.
  ///
  /// In en, this message translates to:
  /// **'File not found.'**
  String get error_file_not_found;

  /// No description provided for @error_could_not_read_file.
  ///
  /// In en, this message translates to:
  /// **'Could not read file content.'**
  String get error_could_not_read_file;

  /// No description provided for @error_unsupported_format.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format.'**
  String get error_unsupported_format;

  /// No description provided for @error_document_parse.
  ///
  /// In en, this message translates to:
  /// **'Failed to open or parse the document.'**
  String get error_document_parse;

  /// No description provided for @error_image_path.
  ///
  /// In en, this message translates to:
  /// **'Could not get image path.'**
  String get error_image_path;

  /// No description provided for @error_open_journey.
  ///
  /// In en, this message translates to:
  /// **'Failed to open the journey.'**
  String get error_open_journey;

  /// No description provided for @error_contact_link.
  ///
  /// In en, this message translates to:
  /// **'Could not open contact link'**
  String get error_contact_link;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get history_title;

  /// No description provided for @history_empty.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get history_empty;

  /// No description provided for @history_no_chats.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get history_no_chats;

  /// No description provided for @history_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get history_search_placeholder;

  /// No description provided for @history_no_matching_chats.
  ///
  /// In en, this message translates to:
  /// **'No matching chats found.'**
  String get history_no_matching_chats;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get copied_to_clipboard;

  /// No description provided for @model_not_ready_warning.
  ///
  /// In en, this message translates to:
  /// **'Please select and download a model first.'**
  String get model_not_ready_warning;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get settings_done;

  /// No description provided for @settings_section_experience.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE'**
  String get settings_section_experience;

  /// No description provided for @settings_section_privacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY & SECURITY'**
  String get settings_section_privacy;

  /// No description provided for @settings_section_support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get settings_section_support;

  /// No description provided for @settings_memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get settings_memory;

  /// No description provided for @settings_memory_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage what the AI remembers'**
  String get settings_memory_subtitle;

  /// No description provided for @settings_app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settings_app_settings;

  /// No description provided for @settings_app_settings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance - Text size'**
  String get settings_app_settings_subtitle;

  /// No description provided for @settings_ai_personalization.
  ///
  /// In en, this message translates to:
  /// **'AI Personalization'**
  String get settings_ai_personalization;

  /// No description provided for @settings_ai_personalization_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tailor responses to your style'**
  String get settings_ai_personalization_subtitle;

  /// No description provided for @settings_data_privacy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy & Security'**
  String get settings_data_privacy;

  /// No description provided for @settings_data_privacy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Passcode - Data deletion'**
  String get settings_data_privacy_subtitle;

  /// No description provided for @settings_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settings_contact_support;

  /// No description provided for @settings_export_debug_logs.
  ///
  /// In en, this message translates to:
  /// **'Export debug logs'**
  String get settings_export_debug_logs;

  /// No description provided for @settings_export_debug_logs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shares DataSapien SDK diagnostics (may include recent chat content). For support troubleshooting only.'**
  String get settings_export_debug_logs_subtitle;

  /// No description provided for @settings_export_debug_logs_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare or share diagnostics'**
  String get settings_export_debug_logs_failed;

  /// No description provided for @settings_powered_by.
  ///
  /// In en, this message translates to:
  /// **'powered by DataSapien'**
  String get settings_powered_by;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// No description provided for @settings_memory_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Memory settings'**
  String get settings_memory_screen_title;

  /// No description provided for @settings_memory_header_title.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get settings_memory_header_title;

  /// No description provided for @settings_memory_header_body.
  ///
  /// In en, this message translates to:
  /// **'Memory allows your assistant to learn from your conversations to provide more personalized and relevant responses over time.'**
  String get settings_memory_header_body;

  /// No description provided for @settings_section_preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get settings_section_preferences;

  /// No description provided for @settings_use_memories.
  ///
  /// In en, this message translates to:
  /// **'Use memories'**
  String get settings_use_memories;

  /// No description provided for @settings_use_memories_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant will remember details from your chats'**
  String get settings_use_memories_subtitle;

  /// No description provided for @settings_auto_learn.
  ///
  /// In en, this message translates to:
  /// **'Auto learn from conversations'**
  String get settings_auto_learn;

  /// No description provided for @settings_auto_learn_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically improve based on your interactions'**
  String get settings_auto_learn_subtitle;

  /// No description provided for @settings_app_settings_screen_title.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settings_app_settings_screen_title;

  /// No description provided for @settings_section_appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settings_section_appearance;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_dark_mode_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get settings_dark_mode_subtitle;

  /// No description provided for @settings_section_text_size.
  ///
  /// In en, this message translates to:
  /// **'TEXT SIZE'**
  String get settings_section_text_size;

  /// No description provided for @settings_text_size_sample.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog.'**
  String get settings_text_size_sample;

  /// No description provided for @settings_text_size_hint.
  ///
  /// In en, this message translates to:
  /// **'Adjust the slider below to change text size.'**
  String get settings_text_size_hint;

  /// No description provided for @settings_text_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settings_text_size_small;

  /// No description provided for @settings_text_size_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settings_text_size_default;

  /// No description provided for @settings_text_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settings_text_size_large;

  /// No description provided for @settings_text_size_huge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get settings_text_size_huge;

  /// No description provided for @settings_privacy_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settings_privacy_screen_title;

  /// No description provided for @settings_section_data_privacy.
  ///
  /// In en, this message translates to:
  /// **'DATA PRIVACY'**
  String get settings_section_data_privacy;

  /// No description provided for @settings_data_privacy_desc.
  ///
  /// In en, this message translates to:
  /// **'Your conversations and data are stored locally. You can delete all chat history and local data at any time.'**
  String get settings_data_privacy_desc;

  /// No description provided for @settings_data_privacy_delete_warning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently wipe all your chat history, inferred memories, and downloaded AI models. This action is stored on your device and cannot be reversed.'**
  String get settings_data_privacy_delete_warning;

  /// No description provided for @settings_delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete all chat and Data'**
  String get settings_delete_all_data;

  /// No description provided for @settings_section_security.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get settings_section_security;

  /// No description provided for @settings_passcode_lock.
  ///
  /// In en, this message translates to:
  /// **'Passcode Lock'**
  String get settings_passcode_lock;

  /// No description provided for @settings_passcode_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settings_passcode_on;

  /// No description provided for @settings_passcode_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settings_passcode_off;

  /// No description provided for @settings_passcode_desc.
  ///
  /// In en, this message translates to:
  /// **'Passcode protection secures app access. Data is stored on your device.'**
  String get settings_passcode_desc;

  /// No description provided for @settings_delete_all_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get settings_delete_all_dialog_title;

  /// No description provided for @settings_delete_all_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all chat history, local data, and downloaded AI models. This cannot be undone.'**
  String get settings_delete_all_dialog_content;

  /// No description provided for @settings_delete_all_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get settings_delete_all_sheet_title;

  /// No description provided for @settings_delete_all_sheet_message.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your conversations, memories, and downloaded AI models. This cannot be undone. Are you absolutely sure?'**
  String get settings_delete_all_sheet_message;

  /// No description provided for @settings_delete_all_sheet_destructive.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get settings_delete_all_sheet_destructive;

  /// No description provided for @settings_deleting_data.
  ///
  /// In en, this message translates to:
  /// **'Deleting Data...'**
  String get settings_deleting_data;

  /// No description provided for @settings_deleting_data_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we clear all local data.'**
  String get settings_deleting_data_subtitle;

  /// No description provided for @settings_deleted_title.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get settings_deleted_title;

  /// No description provided for @settings_deleted_message.
  ///
  /// In en, this message translates to:
  /// **'All your chat history and data has been cleared.'**
  String get settings_deleted_message;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @all_data_deleted.
  ///
  /// In en, this message translates to:
  /// **'All chat and data deleted'**
  String get all_data_deleted;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profile_close;

  /// No description provided for @profile_journeys.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get profile_journeys;

  /// No description provided for @profile_my_data.
  ///
  /// In en, this message translates to:
  /// **'My Data'**
  String get profile_my_data;

  /// No description provided for @no_journeys.
  ///
  /// In en, this message translates to:
  /// **'No Journeys Available'**
  String get no_journeys;

  /// No description provided for @no_inferred_data.
  ///
  /// In en, this message translates to:
  /// **'No inferred data yet. Chat more so the AI can learn about you!'**
  String get no_inferred_data;

  /// No description provided for @profile_my_data_history_title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get profile_my_data_history_title;

  /// No description provided for @my_data_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this data.'**
  String get my_data_delete_failed;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @ok_button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok_button;

  /// No description provided for @passcode_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter passcode'**
  String get passcode_enter;

  /// No description provided for @passcode_enter_new.
  ///
  /// In en, this message translates to:
  /// **'Enter new passcode'**
  String get passcode_enter_new;

  /// No description provided for @passcode_confirm_new.
  ///
  /// In en, this message translates to:
  /// **'Confirm new passcode'**
  String get passcode_confirm_new;

  /// No description provided for @passcode_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passcodes do not match'**
  String get passcode_mismatch;

  /// No description provided for @passcode_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passcode'**
  String get passcode_incorrect;

  /// No description provided for @attachment_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get attachment_sheet_title;

  /// No description provided for @attachment_sheet_documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get attachment_sheet_documents;

  /// No description provided for @attachment_sheet_scan_text.
  ///
  /// In en, this message translates to:
  /// **'Scan Text'**
  String get attachment_sheet_scan_text;

  /// No description provided for @attachment_scanned_document_name.
  ///
  /// In en, this message translates to:
  /// **'Scanned Document.txt'**
  String get attachment_scanned_document_name;

  /// No description provided for @attachment_scanner_unsupported.
  ///
  /// In en, this message translates to:
  /// **'Document scanning is not supported on this device.'**
  String get attachment_scanner_unsupported;

  /// No description provided for @attachment_scanner_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan documents.'**
  String get attachment_scanner_permission_denied;

  /// No description provided for @attachment_scanner_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan document. Please try again.'**
  String get attachment_scanner_failed;

  /// No description provided for @attachment_document_parse_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected document.'**
  String get attachment_document_parse_failed;

  /// No description provided for @attached_document_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Attached Document'**
  String get attached_document_subtitle;

  /// No description provided for @hfSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Hugging Face Models'**
  String get hfSearchTitle;

  /// No description provided for @hfSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search GGUF models...'**
  String get hfSearchPlaceholder;

  /// No description provided for @hfWarningUntested.
  ///
  /// In en, this message translates to:
  /// **'These models are not tested by Pocket Models'**
  String get hfWarningUntested;

  /// No description provided for @hfSearchError.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get hfSearchError;

  /// No description provided for @hfNoResults.
  ///
  /// In en, this message translates to:
  /// **'No models found. Try a different search.'**
  String get hfNoResults;

  /// No description provided for @hfSearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Search to find downloadable GGUF models.'**
  String get hfSearchIntro;

  /// No description provided for @hfNoGgufFiles.
  ///
  /// In en, this message translates to:
  /// **'No GGUF files found in this repository.'**
  String get hfNoGgufFiles;

  /// No description provided for @hfSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select a GGUF File'**
  String get hfSelectFile;

  /// No description provided for @hfAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get hfAddButton;

  /// No description provided for @hfFileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load files. Please try again.'**
  String get hfFileLoadError;

  /// No description provided for @hfSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get hfSearchAction;

  /// No description provided for @hf_model_added_toast.
  ///
  /// In en, this message translates to:
  /// **'Model added! You can download it from the Models page.'**
  String get hf_model_added_toast;

  /// No description provided for @hf_model_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save model'**
  String get hf_model_save_failed;

  /// No description provided for @model_download_failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get model_download_failed;

  /// No description provided for @hf_add_models_button.
  ///
  /// In en, this message translates to:
  /// **'Add Models from Hugging Face'**
  String get hf_add_models_button;

  /// No description provided for @settings_ai_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settings_ai_save;

  /// No description provided for @settings_add_custom_prompt.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Prompt'**
  String get settings_add_custom_prompt;

  /// No description provided for @settings_prompt_profiles.
  ///
  /// In en, this message translates to:
  /// **'PROMPT PROFILES'**
  String get settings_prompt_profiles;

  /// No description provided for @settings_response_style.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE STYLE'**
  String get settings_response_style;

  /// No description provided for @settings_style_concise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get settings_style_concise;

  /// No description provided for @settings_style_balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get settings_style_balanced;

  /// No description provided for @settings_style_detailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get settings_style_detailed;

  /// No description provided for @settings_style_footer_concise.
  ///
  /// In en, this message translates to:
  /// **'CONCISE'**
  String get settings_style_footer_concise;

  /// No description provided for @settings_style_footer_detailed.
  ///
  /// In en, this message translates to:
  /// **'DETAILED'**
  String get settings_style_footer_detailed;

  /// No description provided for @settings_advanced_settings.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED SETTINGS'**
  String get settings_advanced_settings;

  /// No description provided for @settings_context_window.
  ///
  /// In en, this message translates to:
  /// **'Context Window'**
  String get settings_context_window;

  /// No description provided for @settings_context_window_note.
  ///
  /// In en, this message translates to:
  /// **'Higher context allows for longer conversations but will restart the model upon saving.'**
  String get settings_context_window_note;

  /// No description provided for @settings_section_hugging_face.
  ///
  /// In en, this message translates to:
  /// **'HUGGING FACE'**
  String get settings_section_hugging_face;

  /// No description provided for @inference_toast_title.
  ///
  /// In en, this message translates to:
  /// **'I found this about you:'**
  String get inference_toast_title;

  /// No description provided for @inference_toast_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inference_toast_add;

  /// No description provided for @inference_toast_reject.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inference_toast_reject;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
