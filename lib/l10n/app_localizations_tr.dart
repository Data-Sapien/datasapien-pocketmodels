// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get app_title => 'Pocket Models';

  @override
  String get welcome_title => 'Pocket Models';

  @override
  String get welcome_subtitle => 'Tamamen cihazınızda çalışan güçlü yapay zeka';

  @override
  String get welcome_desc1 => 'Sohbetleriniz her zaman gizli kalır';

  @override
  String get welcome_desc2 => 'Abonelik yok, bulut yok, taviz yok';

  @override
  String get continue_button => 'Devam Et';

  @override
  String get back_button => 'Geri';

  @override
  String get features_title => 'Özellikler';

  @override
  String get features_private_title => '%100 Gizli';

  @override
  String get features_private_desc =>
      'Her şey cihazınızda kalır. Verileriniz hiçbir zaman iPhone\'unuzdan ayrılmaz.';

  @override
  String get features_free_title => 'Tamamen Ücretsiz';

  @override
  String get features_free_desc =>
      'Abonelik yok, gizli ücret yok. Sonsuza kadar sizin.';

  @override
  String get features_voice_title => 'Hızlı Ses Modu';

  @override
  String get features_voice_desc =>
      'Şimşek hızında ses tanıma ile doğal sohbetler.';

  @override
  String get features_vision_title => 'Görüntü İşleme';

  @override
  String get features_vision_desc =>
      'Görüntüleri ve sahneleri tamamen cihazınızda güvenle analiz edin.';

  @override
  String get features_docs_title => 'Belgeler ve Fotoğraflar';

  @override
  String get features_docs_desc =>
      'Metinleri, PDF\'leri ve fotoğrafları güvenle analiz edin.';

  @override
  String get splash_powered_by => 'DataSapien tarafından desteklenmektedir';

  @override
  String get model_row_download => 'İndir';

  @override
  String get model_row_downloaded => 'İndirildi';

  @override
  String get model_row_queued => 'Sırada';

  @override
  String get features_web_title => 'Web Araması';

  @override
  String get features_web_desc => 'En güncel bilgileri anında bulun.';

  @override
  String get features_memory_title => 'Hafıza';

  @override
  String get features_memory_desc =>
      'Sohbetlerinizdeki önemli detayları hatırlar.';

  @override
  String get features_custom_title => 'Tamamen Özelleştirilebilir';

  @override
  String get features_custom_desc =>
      'Yapay zeka modellerinizi, temalarınızı seçin ve deneyiminizi kişiselleştirin.';

  @override
  String get models_title => 'Yapay Zeka Modelinizi Seçin';

  @override
  String get models_subtitle => 'Uygulamanıza güç katacak zeka motorunu seçin.';

  @override
  String get models_loading => 'Modeller yükleniyor...';

  @override
  String get models_error => 'Yapay zeka modelleri yüklenemedi.';

  @override
  String get onboarding_models_empty =>
      'Kullanılabilir model yok. Daha sonra tekrar deneyin.';

  @override
  String get chat_input_placeholder => 'Mesaj';

  @override
  String get chat_hint_placeholder => 'Mesaj yazın...';

  @override
  String get chat_model_downloading => 'İndiriliyor...';

  @override
  String get chat_model_loading => 'Model Yükleniyor...';

  @override
  String get chat_model_ready => 'Hazır';

  @override
  String get chat_empty_heading => 'Bugün size nasıl yardımcı olabilirim?';

  @override
  String get chat_empty_hint =>
      'Özel yapay zekanızla sohbet etmeye başlamak için aşağıya bir mesaj yazın. En iyi sonuçlar için net ve belirgin sorular sorun.';

  @override
  String get chat_deleted => 'Sohbet silindi';

  @override
  String get see_attached_document => 'Ekli belgeye bakın';

  @override
  String get attached_image_subtitle => 'Ekli Görsel';

  @override
  String get select_model => 'Model Seç';

  @override
  String get select_model_sheet_title => 'Model Seç';

  @override
  String get select_model_sheet_loading => 'Modeller yükleniyor...';

  @override
  String get select_model_sheet_error => 'Modeller yüklenemedi.';

  @override
  String get model_delete_dialog_title => 'Modeli Sil';

  @override
  String model_delete_dialog_message(String modelName) {
    return '$modelName modelini silmek istediğinizden emin misiniz? Bu işlem cihazınızdan kaldırır.';
  }

  @override
  String get model_delete_dialog_confirm => 'Sil';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get default_model => 'Varsayılan model';

  @override
  String get new_chat => 'Yeni sohbet';

  @override
  String get error_generic_response => 'Yanıt oluşturulamadı.';

  @override
  String get error_context_size =>
      'Mesaj uzunluğu sınırı aştı. Lütfen yeni bir sohbet başlatın.';

  @override
  String get error_init_context =>
      'Model başlatılamadı. Lütfen tekrar deneyin.';

  @override
  String get error_decoding => 'Model yanıtı çözümlenemedi.';

  @override
  String get error_empty_message => 'Gönderilecek mesaj bulunamadı.';

  @override
  String get error_file_not_found => 'Dosya bulunamadı.';

  @override
  String get error_could_not_read_file => 'Dosya içeriği okunamadı.';

  @override
  String get error_unsupported_format => 'Desteklenmeyen dosya biçimi.';

  @override
  String get error_document_parse => 'Belge açılamadı veya ayrıştırılamadı.';

  @override
  String get error_image_path => 'Görüntü yolu alınamadı.';

  @override
  String get error_open_journey => 'Yolculuk açılamadı.';

  @override
  String get error_contact_link => 'İletişim bağlantısı açılamadı';

  @override
  String get history_title => 'Sohbet Geçmişi';

  @override
  String get history_empty => 'Henüz bir geçmişiniz yok.';

  @override
  String get history_no_chats => 'Henüz sohbet yok';

  @override
  String get history_search_placeholder => 'Sohbetlerde ara';

  @override
  String get history_no_matching_chats => 'Eşleşen sohbet bulunamadı.';

  @override
  String get copied_to_clipboard => 'Panoya kopyalandı.';

  @override
  String get model_not_ready_warning =>
      'Lütfen önce bir model seçin ve indirin.';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_done => 'Tamam';

  @override
  String get settings_section_experience => 'DENEYİM';

  @override
  String get settings_section_privacy => 'GİZLİLİK VE GÜVENLİK';

  @override
  String get settings_section_support => 'DESTEK';

  @override
  String get settings_memory => 'Hafıza';

  @override
  String get settings_memory_subtitle =>
      'Yapay zekanın neleri hatırlayacağını yönetin';

  @override
  String get settings_app_settings => 'Uygulama Ayarları';

  @override
  String get settings_app_settings_subtitle => 'Görünüm - Metin boyutu';

  @override
  String get settings_ai_personalization => 'Yapay Zeka Kişiselleştirme';

  @override
  String get settings_ai_personalization_subtitle =>
      'Yanıtları tarzınıza göre uyarlayın';

  @override
  String get settings_data_privacy => 'Veri Gizliliği ve Güvenlik';

  @override
  String get settings_data_privacy_subtitle => 'Şifre - Veri silme';

  @override
  String get settings_contact_support => 'Bize ulaşın';

  @override
  String get settings_export_debug_logs => 'Hata ayıklama günlüğünü dışa aktar';

  @override
  String get settings_export_debug_logs_subtitle =>
      'DataSapien SDK tanılama günlüklerini paylaşır (son sohbet içeriği dahil olabilir). Yalnızca destek sorun giderme için.';

  @override
  String get settings_export_debug_logs_failed =>
      'Tanılama günlüğü hazırlanamadı veya paylaşılamadı';

  @override
  String get settings_powered_by => 'DataSapien tarafından desteklenmektedir';

  @override
  String settings_version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settings_memory_screen_title => 'Hafıza ayarları';

  @override
  String get settings_memory_header_title => 'Deneyiminizi kişiselleştirin';

  @override
  String get settings_memory_header_body =>
      'Hafıza, asistanınızın zaman içinde daha kişiselleştirilmiş ve ilgili yanıtlar sunabilmesi için sohbetlerinizden öğrenmesini sağlar.';

  @override
  String get settings_section_preferences => 'TERCİHLER';

  @override
  String get settings_use_memories => 'Hafızaları kullan';

  @override
  String get settings_use_memories_subtitle =>
      'Asistan sohbetlerinizden detayları hatırlayacak';

  @override
  String get settings_auto_learn => 'Sohbetlerden otomatik öğren';

  @override
  String get settings_auto_learn_subtitle =>
      'Etkileşimlerinize göre otomatik iyileştirin';

  @override
  String get settings_app_settings_screen_title => 'Uygulama Ayarları';

  @override
  String get settings_section_appearance => 'GÖRÜNÜM';

  @override
  String get settings_dark_mode => 'Karanlık Mod';

  @override
  String get settings_dark_mode_subtitle => 'Karanlık tema kullan';

  @override
  String get settings_section_text_size => 'METİN BOYUTU';

  @override
  String get settings_text_size_sample =>
      'The quick brown fox jumps over the lazy dog.';

  @override
  String get settings_text_size_hint =>
      'Metin boyutunu değiştirmek için aşağıdaki kaydırıcıyı ayarlayın.';

  @override
  String get settings_text_size_small => 'Küçük';

  @override
  String get settings_text_size_default => 'Varsayılan';

  @override
  String get settings_text_size_large => 'Büyük';

  @override
  String get settings_text_size_huge => 'Çok Büyük';

  @override
  String get settings_privacy_screen_title => 'Gizlilik ve Güvenlik';

  @override
  String get settings_section_data_privacy => 'VERİ GİZLİLİĞİ';

  @override
  String get settings_data_privacy_desc =>
      'Sohbetleriniz ve verileriniz yerel olarak saklanır. Tüm sohbet geçmişini ve yerel verileri istediğiniz zaman silebilirsiniz.';

  @override
  String get settings_data_privacy_delete_warning =>
      'Bu işlem tüm sohbet geçmişinizi, çıkarılan anıları ve indirilmiş yapay zekâ modellerini kalıcı olarak silecektir. Bu işlem cihazınızda yerel olarak yapılır ve geri alınamaz.';

  @override
  String get settings_delete_all_data => 'Tüm sohbeti ve veriyi sil';

  @override
  String get settings_section_security => 'GÜVENLİK';

  @override
  String get settings_passcode_lock => 'Şifre kilidi';

  @override
  String get settings_passcode_on => 'Açık';

  @override
  String get settings_passcode_off => 'Kapalı';

  @override
  String get settings_passcode_desc =>
      'Şifre koruması uygulama erişimini güvence altına alır. Veriler cihazınızda saklanır.';

  @override
  String get settings_delete_all_dialog_title => 'Tüm veriler silinsin mi?';

  @override
  String get settings_delete_all_dialog_content =>
      'Bu işlem tüm sohbet geçmişini, yerel verileri ve indirilmiş yapay zekâ modellerini kalıcı olarak silecektir. Bu işlem geri alınamaz.';

  @override
  String get settings_delete_all_sheet_title => 'Tüm Veriler Silinsin mi?';

  @override
  String get settings_delete_all_sheet_message =>
      'Bu işlem tüm sohbetlerinizi, anılarınızı ve indirilmiş yapay zekâ modellerini kalıcı olarak silecektir; geri alınamaz. Emin misiniz?';

  @override
  String get settings_delete_all_sheet_destructive => 'Her Şeyi Sil';

  @override
  String get settings_deleting_data => 'Veriler siliniyor...';

  @override
  String get settings_deleting_data_subtitle =>
      'Lütfen tüm yerel veriler temizlenirken bekleyin.';

  @override
  String get settings_deleted_title => 'Silindi';

  @override
  String get settings_deleted_message =>
      'Tüm sohbet geçmişiniz ve verileriniz temizlendi.';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get all_data_deleted => 'Tüm sohbet ve veriler silindi';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_close => 'Kapat';

  @override
  String get profile_journeys => 'Yolculuklar';

  @override
  String get profile_my_data => 'Verilerim';

  @override
  String get no_journeys => 'Henüz yolculuk yok';

  @override
  String get no_inferred_data =>
      'Henüz çıkarılan veri yok. Yapay zekanın sizi tanıması için daha fazla sohbet edin!';

  @override
  String get profile_my_data_history_title => 'Geçmiş';

  @override
  String get my_data_delete_failed => 'Bu veri silinemedi.';

  @override
  String get error_title => 'Hata';

  @override
  String get ok_button => 'Tamam';

  @override
  String get passcode_enter => 'Şifreyi girin';

  @override
  String get passcode_enter_new => 'Yeni şifre girin';

  @override
  String get passcode_confirm_new => 'Yeni şifreyi onaylayın';

  @override
  String get passcode_mismatch => 'Şifreler eşleşmiyor';

  @override
  String get passcode_incorrect => 'Yanlış şifre';

  @override
  String get attachment_sheet_title => 'Ekle';

  @override
  String get attachment_sheet_documents => 'Belgeler';

  @override
  String get attachment_sheet_scan_text => 'Metni Tara';

  @override
  String get attachment_scanned_document_name => 'Taranan Belge.txt';

  @override
  String get attachment_scanner_unsupported =>
      'Bu cihazda belge tarama desteklenmiyor.';

  @override
  String get attachment_scanner_permission_denied =>
      'Belge taramak için kamera izni gerekiyor.';

  @override
  String get attachment_scanner_failed =>
      'Belge taranamadı. Lütfen tekrar deneyin.';

  @override
  String get attachment_document_parse_failed => 'Seçilen belge okunamadı.';

  @override
  String get attached_document_subtitle => 'Ekli Belge';

  @override
  String get hfSearchTitle => 'Hugging Face Modelleri';

  @override
  String get hfSearchPlaceholder => 'GGUF modelleri ara...';

  @override
  String get hfWarningUntested =>
      'Bu modeller Pocket Models tarafından test edilmemiştir';

  @override
  String get hfSearchError => 'Arama başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get hfNoResults => 'Model bulunamadı. Farklı bir arama deneyin.';

  @override
  String get hfSearchIntro =>
      'İndirilebilir GGUF modelleri bulmak için arayın.';

  @override
  String get hfNoGgufFiles => 'Bu depoda GGUF dosyası bulunamadı.';

  @override
  String get hfSelectFile => 'Bir GGUF Dosyası Seçin';

  @override
  String get hfAddButton => 'Ekle';

  @override
  String get hfFileLoadError => 'Dosyalar yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get hfSearchAction => 'Ara';

  @override
  String get hf_model_added_toast =>
      'Model eklendi! İndirmek için Modeller sayfasını kullanın.';

  @override
  String get hf_model_save_failed => 'Model kaydedilemedi';

  @override
  String get model_download_failed => 'İndirme başarısız';

  @override
  String get hf_add_models_button => 'Hugging Face\'den Model Ekle';

  @override
  String get settings_ai_save => 'Kaydet';

  @override
  String get settings_add_custom_prompt => 'Özel İstem Ekle';

  @override
  String get settings_prompt_profiles => 'İSTEM PROFİLLERİ';

  @override
  String get settings_response_style => 'YANIT TARZI';

  @override
  String get settings_style_concise => 'Öz';

  @override
  String get settings_style_balanced => 'Dengeli';

  @override
  String get settings_style_detailed => 'Ayrıntılı';

  @override
  String get settings_style_footer_concise => 'ÖZ';

  @override
  String get settings_style_footer_detailed => 'AYRINTILI';

  @override
  String get settings_advanced_settings => 'GELİŞMİŞ AYARLAR';

  @override
  String get settings_context_window => 'Bağlam Penceresi';

  @override
  String get settings_context_window_note =>
      'Daha yüksek bağlam daha uzun sohbetlere izin verir ancak kaydettiğinizde modeli yeniden başlatır.';

  @override
  String get settings_section_hugging_face => 'HUGGING FACE';

  @override
  String get inference_toast_title => 'Hakkınızda bunu buldum:';

  @override
  String get inference_toast_add => 'Ekle';

  @override
  String get inference_toast_reject => 'Kapat';
}
