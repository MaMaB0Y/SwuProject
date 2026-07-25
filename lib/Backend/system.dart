import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:crypto/crypto.dart";
import "dart:convert";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart" as tz;
import "package:flutter_timezone/flutter_timezone.dart";
import "package:logger/logger.dart";
import "dart:async";

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    printEmojis: true,
  )
);

Future<void> write(
  {required String name, 
  required String surname, 
  required String phone, 
  required String password}) async
{
  final String hashed = _hash(password: password);
  const storage = FlutterSecureStorage();
  await Future.wait([
    storage.write(key: "Name", value: name),
    storage.write(key: "Surname", value: surname),
    storage.write(key: "Phone", value: phone),
    storage.write(key: "Password", value: hashed)]);
}
Future<bool> readcompare({required String password}) async
{
  const storage = FlutterSecureStorage();
  String? localpassword = await storage.read(key: "Password");
  var comparepassword = sha256.convert(utf8.encode(password)).toString();
  if (comparepassword == localpassword)
  {
    return true;
  }
  else
  {
    return false;
  }
}
String _hash({required String password})
{
  return sha256.convert(utf8.encode(password)).toString();
}
class MedicationJSON //For Medication information
{
  final String id;
  final String name;
  final String date;
  final String time;
  final double dosage;
  final String notes;
  MedicationJSON({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.dosage,
    required this.notes});

  Map<String, dynamic> toJson() =>  //Constructor for information to json
  {
    'id' : id,
    'name' : name,
    'date' : date,
    'time' : time,
    'dosage' : dosage,
    'notes' : notes
  };

  factory MedicationJSON.fromJson(Map<String, dynamic> json) => MedicationJSON( //Constructor for json to information
    id: json['id'],
    name: json['name'],
    date: json['date'],
    time: json['time'],
    dosage: (json['dosage'] as num).toDouble(),
    notes: json['notes']
  );
}
class NotificationService
{
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async
  {
    tz.initializeTimeZones();
    final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const androidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosSetting = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSetting, iOS: iosSetting);
    await _notificationsPlugin.initialize(settings: settings);
    await requestPermission();
  }
  Future<void> requestPermission() async 
  {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }
  Future<void> scheduleMedNotification(MedicationJSON med) async
  {
    List<String> dateParts = med.date.split("/");
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    List<String> hourMin = med.time.split(":");
    int hour = int.parse(hourMin[0]);
    int minute = int.parse(hourMin[1]);
    final scheduleDate = tz.TZDateTime(
      tz.local, 
      year,
      month,
      day,
      hour,
      minute);
    if (scheduleDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    int notificationID = med.id.hashCode;

    await _notificationsPlugin.zonedSchedule(id: notificationID, title: "ถึงเวลาทานยา: ${med.name}", body: "ปริมาณ: ${med.dosage} mg\nหมายเหตุ: ${med.notes.isEmpty ? "-" : med.notes}",
    scheduledDate: scheduleDate, 
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        "med_reminder_channel",
        "Medication Reminder",
        channelDescription: "Notification for scheduled medications",
        importance: Importance.max,
        priority: Priority.high),),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }
  Future<void> showInstantNotification() async 
  { //This is for testing purpose
    
    await _notificationsPlugin.zonedSchedule(
      id: 99999,
      title: "Test!",
      body: "This is a notification!",
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)), // 5 seconds from now
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_channel',
          'Medication Reminder',
          channelDescription: 'Notification for scheduled medications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    await _notificationsPlugin.show(
      id: 123456,
      title: "Test!!!",
      body: "Notification works! Yippe!",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'Test_Channel',
          'Test!',
          channelDescription: 'Notification Tester!',
          importance: Importance.max,
          priority: Priority.high,
        ),
        
    ));
  }

  void startClockLogger()
  /*This is a timer function*/
  {
  Timer.periodic(const Duration(seconds: 5), (timer) {
    final systemNow = DateTime.now();
    final tzNow = tz.TZDateTime.now(tz.local);

    log.i("--------------------------------------------------");
    log.i("📱 System Clock:  $systemNow");
    log.i("🌍 tz.local Clock: $tzNow (${tz.local.name})");
    log.i("--------------------------------------------------");
  });
}
}
