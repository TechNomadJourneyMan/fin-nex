/// Public API for the FinNex in-app AI chat (conversational CFO) feature.
///
/// Exposes the feature-local presentation entities, the streaming chat
/// service abstraction (+ a fake for previews), the Riverpod controller, the
/// chat page widget, and the inline widget / disclaimer building blocks.
library fnx_feat_ai_chat;

export 'src/controllers/chat_controller.dart';
export 'src/entities/chat_message.dart';
export 'src/entities/chat_session.dart';
export 'src/entities/widget_spec.dart';
export 'src/pages/ai_chat_page.dart';
export 'src/providers.dart';
export 'src/services/ai_chat_service.dart';
export 'src/widgets/inline_widget_renderer.dart';
export 'src/widgets/safety_disclaimer.dart';
