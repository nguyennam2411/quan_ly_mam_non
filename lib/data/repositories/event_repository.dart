import '../models/event_model.dart';
import '../models/event_registration_model.dart';
import '../providers/event_provider.dart';

class EventRepository {
  final EventProvider _provider = EventProvider();

  Future<List<EventModel>> getAllEvents() async {
    final response = await _provider.getAllEvents();
    return response.map((e) => EventModel.fromJson(e)).toList();
  }

  Future<List<EventRegistrationModel>> getRegistrationsByStudents(List<String> studentIds) async {
    final response = await _provider.getRegistrationsByStudents(studentIds);
    return response.map((e) => EventRegistrationModel.fromJson(e)).toList();
  }

  Future<List<EventRegistrationModel>> getRegistrationsByEvent(String eventId, List<String> studentIds) async {
    final response = await _provider.getRegistrationsByEvent(eventId, studentIds);
    return response.map((e) => EventRegistrationModel.fromJson(e)).toList();
  }

  Future<void> submitRegistration(EventRegistrationModel registration) async {
    await _provider.submitRegistration(registration.toJson());
  }

  Future<void> createEvent(EventModel event) async {
    await _provider.createEvent(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _provider.deleteEvent(eventId);
  }
}
