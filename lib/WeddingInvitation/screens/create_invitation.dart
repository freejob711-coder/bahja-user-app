import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/constants.dart';
import '../../theme/app_theme.dart';
import '../models/invitation_model.dart';
import '../services/invitation_service.dart';
import '../widgets/invitation_form.dart';

class CreateInvitationScreen extends StatefulWidget {
  @override
  _CreateInvitationScreenState createState() => _CreateInvitationScreenState();
}

class _CreateInvitationScreenState extends State<CreateInvitationScreen>
    with TickerProviderStateMixin {
  final InvitationService _invitationService = InvitationService();
  late TabController _tabController;
  String? _invitationId;
  List<Invitee> _invitees = [];
  bool _isLoading = false;
  File? _invitationImage;
  String _eventType = 'زفاف';
  LatLng? _selectedLocation;
  List<Map<String, dynamic>> _userInvitations = [];

  // Controllers for forms
  final TextEditingController _inviterNameController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _maxGuestsController = TextEditingController(text: '1');
  final TextEditingController _personalMessageController = TextEditingController();
  final TextEditingController _additionalRequirementsController = TextEditingController();

  // Invitee form controllers
  final TextEditingController _inviteeNameController = TextEditingController();
  final TextEditingController _inviteePhoneController = TextEditingController();
  final TextEditingController _inviteeCountController = TextEditingController(text: '1');
  final TextEditingController _searchController = TextEditingController();

  // Filtered list
  List<Invitee> get _filteredInvitees {
    if (_searchController.text.isEmpty) return _invitees;
    final query = _searchController.text.toLowerCase();
    return _invitees.where((i) =>
        i.name.toLowerCase().contains(query) ||
        i.phoneNumber.contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkUserAuth();
    _loadUserInvitations();
    _loadSavedInvitationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inviterNameController.dispose();
    _eventNameController.dispose();
    _locationController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _maxGuestsController.dispose();
    _personalMessageController.dispose();
    _additionalRequirementsController.dispose();
    _inviteeNameController.dispose();
    _inviteePhoneController.dispose();
    _inviteeCountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createNewInvitation() async {
    setState(() {
      _invitationId = null;
      _invitees.clear();
      _invitationImage = null;
      _selectedLocation = null;
    });
    _inviterNameController.clear();
    _eventNameController.clear();
    _locationController.clear();
    _eventDateController.clear();
    _eventTimeController.clear();
    _maxGuestsController.text = '1';
    _personalMessageController.clear();
    _additionalRequirementsController.clear();
    _eventType = 'زفاف';
    await _invitationService.clearNewInvitationData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إنشاء مناسبة جديدة', style: AppTextStyles.medium(context)),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _checkUserAuth() {
    final user = _invitationService.getCurrentUser();
    if (user == null) {
      print('المستخدم غير مسجل الدخول');
    }
  }

  Future<void> _pickImage() async {
    final image = await _invitationService.pickImage();
    if (image != null) {
      setState(() {
        _invitationImage = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.light.background,
              onSurface: AppColors.light.text,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.light.background,
              onSurface: AppColors.light.text,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventTimeController.text = picked.format(context);
      });
    }
  }

Future<void> _pickContactFromPhone() async {
  try {
    // التحقق من حالة إذن جهات الاتصال باستخدام permission_handler
    PermissionStatus status = await Permission.contacts.status;

    if (status.isDenied) {
      // لم يُطلب بعد → اطلبه
      status = await Permission.contacts.request();
      if (!status.isGranted) {
        throw Exception('permission_denied');
      }
    } else if (status.isPermanentlyDenied) {
      // تم الرفض بشكل دائم → افتح الإعدادات
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('إذن مطلوب', style: AppTextStyles.title(context)),
          content: Text(
            'تم تعطيل إذن جهات الاتصال. يرجى تفعيله من إعدادات التطبيق.',
            style: AppTextStyles.medium(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // يفتح الإعدادات مباشرة
              },
              child: Text('الإعدادات', style: AppTextStyles.medium(context)?.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // الآن يمكننا جلب جهات الاتصال بأمان
    final contacts = await FlutterContacts.getContacts(withProperties: true);

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد جهات اتصال على الجهاز', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    // متغير مؤقت للبحث داخل النافذة
    List<Contact> filteredContacts = contacts;

    // عرض النافذة المنبثقة مع حقل بحث
    showDialog(
      context: context,
      builder: (context) {
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.contacts, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('اختر جهة اتصال', style: AppTextStyles.title(context)),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // حقل البحث
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'ابحث في جهات الاتصال...',
                        prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppThemes.customColors(context).inputFillColor,
                      ),
                      style: AppTextStyles.medium(context),
                      onChanged: (value) {
                        setStateInDialog(() {
                          if (value.isEmpty) {
                            filteredContacts = contacts;
                          } else {
                            final query = value.toLowerCase();
                            filteredContacts = contacts.where((contact) {
                              final name = contact.displayName.toLowerCase();
                              final phones = contact.phones.map((p) => p.number).join(' ');
                              return name.contains(query) || phones.contains(query);
                            }).toList();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    // القائمة المفلترة
                    Expanded(
                      child: filteredContacts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_search, size: 48, color: AppColors.grey.withOpacity(0.5)),
                                  SizedBox(height: 8),
                                  Text(
                                    'لا توجد نتائج',
                                    style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = filteredContacts[index];
                                final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(contact.displayName[0], style: TextStyle(color: AppColors.primary)),
                                  ),
                                  title: Text(contact.displayName, style: AppTextStyles.medium(context)),
                                  subtitle: phoneNumber.isNotEmpty
                                      ? Text(phoneNumber, style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey))
                                      : null,
                                  onTap: () {
                                    if (phoneNumber.isNotEmpty) {
                                      setState(() {
                                        _inviteeNameController.text = contact.displayName;
                                        _inviteePhoneController.text = phoneNumber;
                                      });
                                      Navigator.pop(context); // إغلاق النافذة
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('لا يوجد رقم هاتف لهذه الجهة', style: AppTextStyles.medium(context)),
                                          backgroundColor: AppColors.warningColor,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إغلاق', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.secondary)),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              backgroundColor: AppColors.backgroundColor(context),
            );
          },
        );
      },
    );

  } catch (e) {
    print('Error accessing contacts: $e');
    String message = 'حدث خطأ غير متوقع';
    Color color = AppColors.errorColor;

    if (e.toString().contains('permission_denied')) {
      message = 'يجب منح إذن جهات الاتصال.';
      color = AppColors.warningColor;
    } else if (e.toString().contains('permanently_denied')) {
      message = 'الإذن ممنوع بشكل دائم. اذهب إلى الإعدادات.';
      color = AppColors.warningColor;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: AppTextStyles.medium(context)), backgroundColor: color),
    );
  }
}

  Future<void> _addInviteeAndShowShareDialog() async {
    if (_inviteeNameController.text.isEmpty || _inviteePhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال اسم المدعو ورقم الهاتف', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }
    if (_invitationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى حفظ بيانات المناسبة أولاً', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    final invitee = Invitee(
      name: _inviteeNameController.text,
      phoneNumber: _inviteePhoneController.text,
      numberOfPeople: _inviteeCountController.text,
      uuid: Uuid().v4(),
    );

    try {
      await _saveInviteeToFirestore(invitee);
      setState(() {
        _invitees.add(invitee);
      });
      await _saveInviteesLocally();

      _showShareOptionsBottomSheet(invitee);

      _clearInviteeForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الإضافة: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _clearInviteeForm() {
    _inviteeNameController.clear();
    _inviteePhoneController.clear();
    _inviteeCountController.text = '1';
  }

  void _showShareOptionsBottomSheet(Invitee invitee) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('شارك الدعوة مع ${invitee.name}', style: AppTextStyles.large(context)?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ElevatedButton.icon(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     _shareViaWhatsApp(invitee);
                //   },
                //   icon: Icon(Icons.chat, color: Colors.white),
                //   label: Text('واتساب', style: TextStyle(color: Colors.white)),
                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                // ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _generateAndShareQrCode(invitee);
                  },
                  icon: Icon(Icons.share, color: Colors.white),
                  label: Text('مشاركة', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteInvitee(Invitee invitee) async {
    try {
      await _invitationService.deleteInvitee(_invitationId, invitee);
      setState(() {
        _invitees.removeWhere((i) => i.uuid == invitee.uuid);
      });
      await _saveInviteesLocally();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف المدعو بنجاح', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في الحذف: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _saveInvitation() async {
    if (_inviterNameController.text.isEmpty ||
        _eventNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _eventDateController.text.isEmpty ||
        _eventTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تعبئة جميع الحقول الإلزامية', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final newInvitationId = await _invitationService.saveInvitation(
        invitationId: _invitationId,
        inviterName: _inviterNameController.text,
        eventName: _eventNameController.text,
        eventType: _eventType,
        location: _locationController.text,
        eventDate: _eventDateController.text,
        eventTime: _eventTimeController.text,
        maxGuests: _maxGuestsController.text,
        personalMessage: _personalMessageController.text,
        additionalRequirements: _additionalRequirementsController.text,
        invitationImage: _invitationImage,
        selectedLocation: _selectedLocation,
      );
      _invitationId = newInvitationId;
      await _saveInvitationLocally();
      await _saveInviteesLocally();
      await _loadUserInvitations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الدعوة بنجاح', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.successColor,
        ),
      );
      _tabController.animateTo(1); // الانتقال لتبويبة "مدعو جديد"
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveInviteeToFirestore(Invitee invitee) async {
    await _invitationService.saveInviteeToFirestore(_invitationId, invitee);
  }

  Future<void> _saveInvitationLocally() async {
    await _invitationService.saveInvitationLocally(
      invitationId: _invitationId,
      inviterName: _inviterNameController.text,
      eventName: _eventNameController.text,
      eventType: _eventType,
      location: _locationController.text,
      eventDate: _eventDateController.text,
      eventTime: _eventTimeController.text,
      maxGuests: _maxGuestsController.text,
      personalMessage: _personalMessageController.text,
      additionalRequirements: _additionalRequirementsController.text,
      selectedLocation: _selectedLocation,
    );
  }

  Future<void> _saveInviteesLocally() async {
    await _invitationService.saveInviteesLocally(_invitationId, _invitees);
  }

  Future<void> _loadSavedInvitationData() async {
  final data = await _invitationService.loadSavedInvitationData();
  if (data == null) return;

  // أولاً: تحميل البيانات والمدعوين من الذاكرة المحلية
  setState(() {
    _inviterNameController.text = data['inviterName'] ?? '';
    _eventNameController.text = data['eventName'] ?? '';
    _eventType = data['eventType'] ?? 'زفاف';
    _locationController.text = data['location'] ?? '';
    _eventDateController.text = data['eventDate'] ?? '';
    _eventTimeController.text = data['eventTime'] ?? '';
    _maxGuestsController.text = data['maxGuests'] ?? '1';
    _personalMessageController.text = data['personalMessage'] ?? '';
    _additionalRequirementsController.text = data['additionalRequirements'] ?? '';
    _selectedLocation = data['selectedLocation'];

    if (data['invitationId'] != null && data['invitationId'].isNotEmpty) {
      _invitationId = data['invitationId'];
      if (data['invitees'] != null) {
        _invitees = List<Invitee>.from(data['invitees']);
      }
    }
  });

  // ثانياً: محاولة التحديث من Firestore (اختياري، يعتمد على الإنترنت)
  if (_invitationId != null) {
    try {
      final firestoreData = await _invitationService.loadInvitationFromFirestore(_invitationId!);
      if (firestoreData != null) {
        setState(() {
          _inviterNameController.text = firestoreData['inviterName'] ?? _inviterNameController.text;
          _eventNameController.text = firestoreData['eventName'] ?? _eventNameController.text;
          _eventType = firestoreData['eventType'] ?? _eventType;
          _locationController.text = firestoreData['location'] ?? _locationController.text;
          _eventDateController.text = firestoreData['eventDate'] ?? _eventDateController.text;
          _eventTimeController.text = firestoreData['eventTime'] ?? _eventTimeController.text;
          _maxGuestsController.text = (firestoreData['maxGuests'] ?? 1).toString();
          _personalMessageController.text = firestoreData['personalMessage'] ?? _personalMessageController.text;
          _additionalRequirementsController.text = firestoreData['additionalRequirements'] ?? _additionalRequirementsController.text;

          if (firestoreData['locationLatLng'] != null) {
            _selectedLocation = LatLng(
              (firestoreData['locationLatLng'] as GeoPoint).latitude,
              (firestoreData['locationLatLng'] as GeoPoint).longitude,
            );
          }
        });

        // تحميل المدعوين من Firestore (سيؤدي إلى تحديث القائمة + حفظ محلياً)
        await _loadInvitees();
      }
    } catch (e) {
      print('فشل في تحميل البيانات من Firestore: $e');
      // لا مشكلة — نحن نملك النسخة المحلية من _invitees
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('البيانات محملة من الوضع غير المتصل', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }
}
  Future<void> _loadInvitees() async {
    final invitees = await _invitationService.loadInvitees(_invitationId);
    setState(() {
      _invitees = invitees;
    });
    await _saveInviteesLocally();
  }

  Future<void> _loadUserInvitations() async {
    try {
      final invitations = await _invitationService.loadUserInvitations();
      setState(() {
        _userInvitations = invitations;
      });
    } catch (e) {
      print('Error loading invitations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل الدعوات: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _generateAndShareQrCode(Invitee invitee) async {
    try {
      await _invitationService.generateAndShareQrCode(
        invitationId: _invitationId,
        invitee: invitee,
        eventName: _eventNameController.text,
        eventDate: _eventDateController.text,
        eventTime: _eventTimeController.text,
        location: _locationController.text,
        personalMessage: _personalMessageController.text,
        invitationImage: _invitationImage,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في توليد الباركود: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  // Future<void> _shareViaWhatsApp(Invitee invitee) async {
  //   try {
  //     await _invitationService.shareViaWhatsApp(
  //       invitationId: _invitationId,
  //       invitee: invitee,
  //       eventName: _eventNameController.text,
  //       eventDate: _eventDateController.text,
  //       eventTime: _eventTimeController.text,
  //       location: _locationController.text,
  //       personalMessage: _personalMessageController.text,
  //       invitationImage: _invitationImage,
  //       phoneNumber: invitee.phoneNumber,
  //       context: context,
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('حدث خطأ في المشاركة عبر واتساب: ${e.toString()}', style: AppTextStyles.medium(context)),
  //         backgroundColor: AppColors.errorColor,
  //       ),
  //     );
  //   }
  // }

  Future<void> _deleteInvitation(String invitationId) async {
    try {
      await _invitationService.deleteInvitation(invitationId);
      if (_invitationId == invitationId) {
        setState(() {
          _invitationId = null;
          _invitees.clear();
        });
      }
      await _loadUserInvitations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الدعوة بنجاح', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في الحذف: ${e.toString()}', style: AppTextStyles.medium(context)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _editInvitation(Map<String, dynamic> invitation) async {
    setState(() {
      _invitationId = invitation['id'];
      _inviterNameController.text = invitation['inviterName'] ?? '';
      _eventNameController.text = invitation['eventName'] ?? '';
      _eventType = invitation['eventType'] ?? 'زفاف';
      _locationController.text = invitation['location'] ?? '';
      _eventDateController.text = invitation['eventDate'] ?? '';
      _eventTimeController.text = invitation['eventTime'] ?? '';
      _maxGuestsController.text = (invitation['maxGuests'] ?? 1).toString();
      _personalMessageController.text = invitation['personalMessage'] ?? '';
      _additionalRequirementsController.text = invitation['additionalRequirements'] ?? '';
      if (invitation['locationLatLng'] != null) {
        _selectedLocation = LatLng(
          (invitation['locationLatLng'] as GeoPoint).latitude,
          (invitation['locationLatLng'] as GeoPoint).longitude,
        );
      }
    });
    await _loadInvitees();
    await _saveInvitationLocally();
    _tabController.animateTo(0);
  }

  Future<void> _shareEntireInvitation() async {
    if (_invitationId == null) return;

    final directory = await getApplicationDocumentsDirectory();
    List<XFile> filesToShare = [];

    // توليد QR Code عام للدعوة
    final qrData = jsonEncode({
      'invitationId': _invitationId,
      'eventName': _eventNameController.text,
      'eventDate': _eventDateController.text,
      'location': _locationController.text,
    });
    final qrCode = QrCode.fromData(data: qrData, errorCorrectLevel: QrErrorCorrectLevel.L);
    final painter = QrPainter.withQr(qr: qrCode, color: const Color.fromARGB(255, 255, 255, 255));
    final qrFile = File('${directory.path}/full_qr.png');
    final imgData = await painter.toImageData(1024);
    await qrFile.writeAsBytes(imgData!.buffer.asUint8List());
    filesToShare.add(XFile(qrFile.path));

    // إضافة صورة الدعوة إذا كانت موجودة
    if (_invitationImage != null) {
      final imageFile = File('${directory.path}/invitation_share.jpg');
      await imageFile.writeAsBytes(await _invitationImage!.readAsBytes());
      filesToShare.add(XFile(imageFile.path));
    }

    // نص الدعوة
    final message = '''دعوة رسمية لحضور ${_eventNameController.text}
📅 التاريخ: ${_eventDateController.text}
🕐 الوقت: ${_eventTimeController.text}
📍 المكان: ${_locationController.text}
${_personalMessageController.text.isNotEmpty ? '\n${_personalMessageController.text}' : ''}
شكرًا لتقديرك.''';

    await Share.shareXFiles(filesToShare, text: message, subject: 'دعوة: ${_eventNameController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('إدارة الدعوات', style: AppTextStyles.title(context)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.backgroundColor(context),
          labelColor: AppColors.backgroundColor(context),
          unselectedLabelColor: AppColors.backgroundColor(context).withOpacity(0.7),
          labelStyle: AppTextStyles.small(context),
          tabs: [
            Tab(icon: Icon(Icons.person), text: 'انشاء'),
            Tab(icon: Icon(Icons.add), text: 'اضافة مدعو'),
            Tab(icon: Icon(Icons.group), text: 'المدعوين'),
            Tab(icon: Icon(Icons.event), text: 'دعواتي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInviterDataTab(),
          _buildAddInviteeTab(),
          _buildInviteesTab(),
          _buildMyInvitationsTab(),
        ],
      ),
    );
  }

  Widget _buildInviterDataTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.1), AppColors.backgroundColor(context)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_note, size: 60, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text('بيانات المناسبة والداعي', style: AppTextStyles.large(context)?.copyWith(color: AppColors.primary,fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('أدخل جميع البيانات المطلوبة لإنشاء الدعوة', style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InvitationWidget.buildTextField(_inviterNameController, 'اسم الداعي', Icons.person, context),
            InvitationWidget.buildTextField(_eventNameController, 'اسم المناسبة', Icons.event, context),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _eventType,
                decoration: InputDecoration(
                  labelText: 'نوع المناسبة',
                  prefixIcon: Icon(Icons.category, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  labelStyle: AppTextStyles.small(context),
                  filled: true,
                  fillColor: AppThemes.customColors(context).inputFillColor,
                ),
                dropdownColor: AppColors.backgroundColor(context),
                style: AppTextStyles.medium(context),
                items: ['زفاف', 'خطوبة', 'عيد ميلاد', 'تخرج', 'مؤتمر', 'أخرى']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: AppTextStyles.small(context)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _eventType = value!;
                  });
                },
              ),
            ),
            InvitationWidget.buildTextField(_locationController, 'مكان المناسبة', Icons.location_on, context),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: InvitationWidget.buildTextField(_eventDateController, 'تاريخ المناسبة', Icons.calendar_today, context),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: InvitationWidget.buildTextField(_eventTimeController, 'وقت المناسبة', Icons.access_time, context),
              ),
            ),
            InvitationWidget.buildTextField(_maxGuestsController, 'الحد الأقصى للضيوف', Icons.group, context, TextInputType.number),
            InvitationWidget.buildTextField(_personalMessageController, 'رسالة شخصية (اختيارية)', Icons.message, context),
            InvitationWidget.buildTextField(_additionalRequirementsController, 'متطلبات إضافية (اختيارية)', Icons.note, context),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: _invitationImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.file(_invitationImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('إضافة صورة للدعوة (اختيارية)', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InvitationWidget.buildGradientButton('مناسبة جديدة', _createNewInvitation, context, width: double.infinity),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : InvitationWidget.buildGradientButton('حفظ', _saveInvitation, context, width: double.infinity),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInviteeTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [AppColors.secondary.withOpacity(0.1), AppColors.backgroundColor(context)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_circle, size: 60, color: AppColors.secondary),
                    SizedBox(height: 10),
                    Text('إضافة مدعو جديد', style: AppTextStyles.large(context)?.copyWith(color: AppColors.secondary,fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('املأ البيانات وأضف المدعو', style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InvitationWidget.buildTextField(_inviteeNameController, 'اسم المدعو', Icons.person, context),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: _pickContactFromPhone,
                          icon: Icon(Icons.contacts, color: AppColors.primary, size: 28),
                          tooltip: 'اختر من جهات الاتصال',
                        ),
                      ],
                    ),
                    InvitationWidget.buildTextField(_inviteePhoneController, 'رقم الهاتف', Icons.phone, context, TextInputType.phone),
                    InvitationWidget.buildTextField(_inviteeCountController, 'عدد الأشخاص', Icons.group, context, TextInputType.number),
                    SizedBox(height: 20),
                    InvitationWidget.buildGradientButton('إضافة المدعو', () {
                      _addInviteeAndShowShareDialog();
                    }, context, width: double.infinity),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildInviteesTab() {
  if (_invitationId == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 60, color: AppColors.grey),
          SizedBox(height: 16),
          Text('لم يتم تحديد دعوة', style: AppTextStyles.title(context)),
          Text('احفظ الدعوة أولاً لرؤية المدعوين', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
        ],
      ),
    );
  }

  // قائمة مؤقتة تعرض النتائج بعد الفرز
  List<Invitee> filteredList = _filteredInvitees;

  return Container(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'ابحث عن مدعو...',
            hintText: 'أدخل اسم أو رقم الهاتف',
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppThemes.customColors(context).inputFillColor,
          ),
          style: AppTextStyles.medium(context),
          onChanged: (value) {
            // تحديث القائمة تلقائيًا عند كل تغيير في النص
            setState(() {
              // لا حاجة لشيء هنا، لأن _filteredInvitees يُحسب تلقائيًا من getter
            });
          },
        ),
        SizedBox(height: 16),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              final List<Invitee> currentList = value.text.isEmpty
                  ? _invitees
                  : _invitees.where((i) =>
                      i.name.toLowerCase().contains(value.text.toLowerCase()) ||
                      i.phoneNumber.contains(value.text)).toList();

              if (currentList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.grey.withOpacity(0.5)),
                      SizedBox(height: 8),
                      Text(
                        value.text.isEmpty ? 'لا يوجد مدعوين' : 'لا توجد نتائج مطابقة',
                        style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final invitee = currentList[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(invitee.name[0])),
                      title: Text(invitee.name),
                      subtitle: Text('${invitee.phoneNumber} • ${invitee.numberOfPeople} أشخاص'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IconButton(
                          //   icon: Icon(Icons.chat, color: Colors.green),
                          //   onPressed: () => _shareViaWhatsApp(invitee),
                          // ),
                          IconButton(
                            icon: Icon(Icons.share, color: AppColors.primary),
                            onPressed: () => _generateAndShareQrCode(invitee),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteInvitee(invitee),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
       
      ],
    ),
  );
}

  Widget _buildMyInvitationsTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), AppColors.backgroundColor(context)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 60, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text('دعواتي', style: AppTextStyles.extraLarge(context)?.copyWith(color: AppColors.primary)),
                  SizedBox(height: 5),
                  Text('جميع المناسبات التي أنشأتها', style: AppTextStyles.extraSmall(context)?.copyWith(color: AppColors.grey)),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _userInvitations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: AppColors.grey.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text('لم تقم بإنشاء أي دعوات بعد', style: AppTextStyles.large(context)?.copyWith(color: AppColors.grey)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserInvitations,
                    child: ListView.builder(
                      itemCount: _userInvitations.length,
                      itemBuilder: (context, index) {
                        final invitation = _userInvitations[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            onTap: () => _showInvitationDetails(invitation),
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // عرض صورة الدعوة إن وُجدت
                                      if (invitation['imageUrl'] != null && invitation['imageUrl'].isNotEmpty)
                                        Image.network(invitation['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
                                      else
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.image, color: AppColors.grey),
                                        ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(invitation['eventName'] ?? 'مناسبة', style: AppTextStyles.large(context)),
                                            Text(invitation['eventType'] ?? '', style: AppTextStyles.small(context)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton(
                                        icon: Icon(Icons.more_vert, color: AppColors.grey),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: ListTile(
                                              leading: Icon(Icons.edit, color: AppColors.primary),
                                              title: Text('تعديل', style: AppTextStyles.small(context)),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            value: 'edit',
                                          ),
                                          PopupMenuItem(
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red),
                                              title: Text('حذف', style: AppTextStyles.small(context)),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            value: 'delete',
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editInvitation(invitation);
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(invitation['id']);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                                      SizedBox(width: 4),
                                      Text(invitation['eventDate'] ?? 'تاريخ غير محدد',
                                        style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                                      SizedBox(width: 16),
                                      Icon(Icons.access_time, size: 16, color: AppColors.grey),
                                      SizedBox(width: 4),
                                      Text(invitation['eventTime'] ?? 'وقت غير محدد',
                                        style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: AppColors.grey),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          invitation['location'] ?? 'مكان غير محدد',
                                          style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showInvitationDetails(Map<String, dynamic> invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: AppColors.backgroundColor(context),
        title: Text(invitation['eventName'] ?? 'تفاصيل المناسبة', style: AppTextStyles.title(context)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InvitationWidget.buildDetailRow('النوع:', invitation['eventType'] ?? 'غير محدد', context),
              InvitationWidget.buildDetailRow('الداعي:', invitation['inviterName'] ?? 'غير محدد', context),
              InvitationWidget.buildDetailRow('التاريخ:', invitation['eventDate'] ?? 'غير محدد', context),
              InvitationWidget.buildDetailRow('الوقت:', invitation['eventTime'] ?? 'غير محدد', context),
              InvitationWidget.buildDetailRow('المكان:', invitation['location'] ?? 'غير محدد', context),
              InvitationWidget.buildDetailRow('الحد الأقصى:', '${invitation['maxGuests'] ?? 1} ضيف', context),
              if (invitation['personalMessage'] != null && invitation['personalMessage'].isNotEmpty)
                InvitationWidget.buildDetailRow('الرسالة:', invitation['personalMessage'], context),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('إغلاق', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.secondary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String invitationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: AppColors.backgroundColor(context),
        title: Text('تأكيد الحذف', style: AppTextStyles.title(context)),
        content: Text('هل أنت متأكد من حذف هذه الدعوة؟ لا يمكن التراجع.', style: AppTextStyles.medium(context)),
        actions: [
          TextButton(
            child: Text('إلغاء', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.secondary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: AppTextStyles.medium(context)?.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteInvitation(invitationId);
            },
          ),
        ],
      ),
    );
  }
}