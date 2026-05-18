// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Pocket Models';

  @override
  String get welcome_title => 'Pocket Models';

  @override
  String get welcome_subtitle => 'Powerful AI, entirely on your device';

  @override
  String get welcome_desc1 => 'Your conversations stay private, always';

  @override
  String get welcome_desc2 => 'No subscriptions, no cloud, no compromises';

  @override
  String get continue_button => 'Continue';

  @override
  String get back_button => 'Back';

  @override
  String get features_title => 'Features';

  @override
  String get features_private_title => '100% Private';

  @override
  String get features_private_desc =>
      'Everything stays on your device. No data ever leaves your iPhone.';

  @override
  String get features_free_title => 'Completely Free';

  @override
  String get features_free_desc =>
      'No subscriptions, no hidden fees. Yours forever.';

  @override
  String get features_voice_title => 'Responsive Voice Mode';

  @override
  String get features_voice_desc =>
      'Natural conversations with lightning-fast speech recognition.';

  @override
  String get features_vision_title => 'Vision AI';

  @override
  String get features_vision_desc =>
      'Analyze images and scenes securely, all on-device.';

  @override
  String get features_docs_title => 'Documents & Photos';

  @override
  String get features_docs_desc => 'Analyze text, PDFs, and photos safely.';

  @override
  String get splash_powered_by => 'powered by DataSapien';

  @override
  String get model_row_download => 'Download';

  @override
  String get model_row_downloaded => 'Downloaded';

  @override
  String get model_row_queued => 'Queued';

  @override
  String get features_web_title => 'Web Search';

  @override
  String get features_web_desc => 'Find the latest information instantly.';

  @override
  String get features_memory_title => 'Memory';

  @override
  String get features_memory_desc =>
      'Remembers what\'s important across chats.';

  @override
  String get features_custom_title => 'Fully Customizable';

  @override
  String get features_custom_desc =>
      'Choose your AI models, themes, and personalize your experience.';

  @override
  String get models_title => 'Choose Your AI Model';

  @override
  String get models_subtitle =>
      'Select the intelligence engine that will power your app.';

  @override
  String get models_loading => 'Loading models...';

  @override
  String get models_error => 'Failed to load AI models.';

  @override
  String get onboarding_models_empty =>
      'No models are available. Try again later.';

  @override
  String get chat_input_placeholder => 'Message';

  @override
  String get chat_hint_placeholder => 'Type a message...';

  @override
  String get chat_model_downloading => 'Downloading...';

  @override
  String get chat_model_loading => 'Loading Model...';

  @override
  String get chat_model_ready => 'Ready';

  @override
  String get chat_empty_heading => 'How can I help you today?';

  @override
  String get chat_empty_hint =>
      'Type a message below to start chatting with your private AI. For best results, ask clear and specific questions.';

  @override
  String get chat_deleted => 'Chat deleted';

  @override
  String get see_attached_document => 'See attached document';

  @override
  String get attached_image_subtitle => 'Attached Image';

  @override
  String get select_model => 'Select Model';

  @override
  String get select_model_sheet_title => 'Select Model';

  @override
  String get select_model_sheet_loading => 'Loading models...';

  @override
  String get select_model_sheet_error => 'Failed to load models.';

  @override
  String get model_delete_dialog_title => 'Delete Model';

  @override
  String model_delete_dialog_message(String modelName) {
    return 'Are you sure you want to delete $modelName? This will remove it from your device.';
  }

  @override
  String get model_delete_dialog_confirm => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get default_model => 'Default model';

  @override
  String get new_chat => 'New chat';

  @override
  String get error_generic_response => 'Failed to generate response.';

  @override
  String get error_context_size =>
      'Message length limit exceeded. Please start a new chat.';

  @override
  String get error_init_context =>
      'Failed to initialize the model. Please try again.';

  @override
  String get error_decoding => 'Could not decode the model\'s response.';

  @override
  String get error_empty_message => 'No message to send was found.';

  @override
  String get error_file_not_found => 'File not found.';

  @override
  String get error_could_not_read_file => 'Could not read file content.';

  @override
  String get error_unsupported_format => 'Unsupported file format.';

  @override
  String get error_document_parse => 'Failed to open or parse the document.';

  @override
  String get error_image_path => 'Could not get image path.';

  @override
  String get error_open_journey => 'Failed to open the journey.';

  @override
  String get error_contact_link => 'Could not open contact link';

  @override
  String get history_title => 'Chat History';

  @override
  String get history_empty => 'No history yet.';

  @override
  String get history_no_chats => 'No chats yet';

  @override
  String get history_search_placeholder => 'Search chats';

  @override
  String get history_no_matching_chats => 'No matching chats found.';

  @override
  String get copied_to_clipboard => 'Copied to clipboard.';

  @override
  String get model_not_ready_warning =>
      'Please select and download a model first.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_done => 'Done';

  @override
  String get settings_section_experience => 'EXPERIENCE';

  @override
  String get settings_section_privacy => 'PRIVACY & SECURITY';

  @override
  String get settings_section_support => 'SUPPORT';

  @override
  String get settings_memory => 'Memory';

  @override
  String get settings_memory_subtitle => 'Manage what the AI remembers';

  @override
  String get settings_app_settings => 'App Settings';

  @override
  String get settings_app_settings_subtitle => 'Appearance - Text size';

  @override
  String get settings_ai_personalization => 'AI Personalization';

  @override
  String get settings_ai_personalization_subtitle =>
      'Tailor responses to your style';

  @override
  String get settings_data_privacy => 'Data Privacy & Security';

  @override
  String get settings_data_privacy_subtitle => 'Passcode - Data deletion';

  @override
  String get settings_contact_support => 'Contact us';

  @override
  String get settings_export_debug_logs => 'Export debug logs';

  @override
  String get settings_export_debug_logs_subtitle =>
      'Shares DataSapien SDK diagnostics (may include recent chat content). For support troubleshooting only.';

  @override
  String get settings_export_debug_logs_failed =>
      'Could not prepare or share diagnostics';

  @override
  String get settings_powered_by => 'powered by DataSapien';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get settings_memory_screen_title => 'Memory settings';

  @override
  String get settings_memory_header_title => 'Personalize your experience';

  @override
  String get settings_memory_header_body =>
      'Memory allows your assistant to learn from your conversations to provide more personalized and relevant responses over time.';

  @override
  String get settings_section_preferences => 'PREFERENCES';

  @override
  String get settings_use_memories => 'Use memories';

  @override
  String get settings_use_memories_subtitle =>
      'Assistant will remember details from your chats';

  @override
  String get settings_auto_learn => 'Auto learn from conversations';

  @override
  String get settings_auto_learn_subtitle =>
      'Automatically improve based on your interactions';

  @override
  String get settings_app_settings_screen_title => 'App Settings';

  @override
  String get settings_section_appearance => 'APPEARANCE';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get settings_dark_mode_subtitle => 'Use dark theme';

  @override
  String get settings_section_text_size => 'TEXT SIZE';

  @override
  String get settings_text_size_sample =>
      'The quick brown fox jumps over the lazy dog.';

  @override
  String get settings_text_size_hint =>
      'Adjust the slider below to change text size.';

  @override
  String get settings_text_size_small => 'Small';

  @override
  String get settings_text_size_default => 'Default';

  @override
  String get settings_text_size_large => 'Large';

  @override
  String get settings_text_size_huge => 'Huge';

  @override
  String get settings_privacy_screen_title => 'Privacy & Security';

  @override
  String get settings_section_data_privacy => 'DATA PRIVACY';

  @override
  String get settings_data_privacy_desc =>
      'Your conversations and data are stored locally. You can delete all chat history and local data at any time.';

  @override
  String get settings_data_privacy_delete_warning =>
      'This will permanently wipe all your chat history, inferred memories, and downloaded AI models. This action is stored on your device and cannot be reversed.';

  @override
  String get settings_delete_all_data => 'Delete all chat and Data';

  @override
  String get settings_section_security => 'SECURITY';

  @override
  String get settings_passcode_lock => 'Passcode Lock';

  @override
  String get settings_passcode_on => 'On';

  @override
  String get settings_passcode_off => 'Off';

  @override
  String get settings_passcode_desc =>
      'Passcode protection secures app access. Data is stored on your device.';

  @override
  String get settings_delete_all_dialog_title => 'Delete all data?';

  @override
  String get settings_delete_all_dialog_content =>
      'This will permanently delete all chat history, local data, and downloaded AI models. This cannot be undone.';

  @override
  String get settings_delete_all_sheet_title => 'Delete All Data?';

  @override
  String get settings_delete_all_sheet_message =>
      'This will permanently delete all your conversations, memories, and downloaded AI models. This cannot be undone. Are you absolutely sure?';

  @override
  String get settings_delete_all_sheet_destructive => 'Delete Everything';

  @override
  String get settings_deleting_data => 'Deleting Data...';

  @override
  String get settings_deleting_data_subtitle =>
      'Please wait while we clear all local data.';

  @override
  String get settings_deleted_title => 'Deleted';

  @override
  String get settings_deleted_message =>
      'All your chat history and data has been cleared.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get all_data_deleted => 'All chat and data deleted';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_close => 'Close';

  @override
  String get profile_journeys => 'Journeys';

  @override
  String get profile_my_data => 'My Data';

  @override
  String get no_journeys => 'No Journeys Available';

  @override
  String get no_inferred_data =>
      'No inferred data yet. Chat more so the AI can learn about you!';

  @override
  String get profile_my_data_history_title => 'History';

  @override
  String get my_data_delete_failed => 'Could not delete this data.';

  @override
  String get error_title => 'Error';

  @override
  String get ok_button => 'OK';

  @override
  String get passcode_enter => 'Enter passcode';

  @override
  String get passcode_enter_new => 'Enter new passcode';

  @override
  String get passcode_confirm_new => 'Confirm new passcode';

  @override
  String get passcode_mismatch => 'Passcodes do not match';

  @override
  String get passcode_incorrect => 'Incorrect passcode';

  @override
  String get attachment_sheet_title => 'Add Attachment';

  @override
  String get attachment_sheet_documents => 'Documents';

  @override
  String get attachment_sheet_scan_text => 'Scan Text';

  @override
  String get attachment_scanned_document_name => 'Scanned Document.txt';

  @override
  String get attachment_scanner_unsupported =>
      'Document scanning is not supported on this device.';

  @override
  String get attachment_scanner_permission_denied =>
      'Camera permission is required to scan documents.';

  @override
  String get attachment_scanner_failed =>
      'Failed to scan document. Please try again.';

  @override
  String get attachment_document_parse_failed =>
      'Could not read the selected document.';

  @override
  String get attached_document_subtitle => 'Attached Document';

  @override
  String get hfSearchTitle => 'Hugging Face Models';

  @override
  String get hfSearchPlaceholder => 'Search GGUF models...';

  @override
  String get hfWarningUntested =>
      'These models are not tested by Pocket Models';

  @override
  String get hfSearchError => 'Search failed. Please try again.';

  @override
  String get hfNoResults => 'No models found. Try a different search.';

  @override
  String get hfSearchIntro => 'Search to find downloadable GGUF models.';

  @override
  String get hfNoGgufFiles => 'No GGUF files found in this repository.';

  @override
  String get hfSelectFile => 'Select a GGUF File';

  @override
  String get hfAddButton => 'Add';

  @override
  String get hfFileLoadError => 'Failed to load files. Please try again.';

  @override
  String get hfSearchAction => 'Search';

  @override
  String get hf_model_added_toast =>
      'Model added! You can download it from the Models page.';

  @override
  String get hf_model_save_failed => 'Could not save model';

  @override
  String get model_download_failed => 'Download failed';

  @override
  String get hf_add_models_button => 'Add Models from Hugging Face';

  @override
  String get settings_ai_save => 'Save';

  @override
  String get settings_add_custom_prompt => 'Add Custom Prompt';

  @override
  String get settings_prompt_profiles => 'PROMPT PROFILES';

  @override
  String get settings_response_style => 'RESPONSE STYLE';

  @override
  String get settings_style_concise => 'Concise';

  @override
  String get settings_style_balanced => 'Balanced';

  @override
  String get settings_style_detailed => 'Detailed';

  @override
  String get settings_style_footer_concise => 'CONCISE';

  @override
  String get settings_style_footer_detailed => 'DETAILED';

  @override
  String get settings_advanced_settings => 'ADVANCED SETTINGS';

  @override
  String get settings_context_window => 'Context Window';

  @override
  String get settings_context_window_note =>
      'Higher context allows for longer conversations but will restart the model upon saving.';

  @override
  String get settings_section_hugging_face => 'HUGGING FACE';

  @override
  String get inference_toast_title => 'I found this about you:';

  @override
  String get inference_toast_add => 'Add';

  @override
  String get inference_toast_reject => 'Dismiss';
}
