import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/constants.dart';
import '../screens/ContactUsPage .dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar مخصص مع تأثيرات جذابة
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CelebrationPainter(),
                      ),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            TweenAnimationBuilder(
                              duration: Duration(seconds: 2),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.shieldHalved,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'سياسة الخصوصية',
                              style: AppTextStyles.heading(context).copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'نحن نقدر خصوصيتك ونحميها',
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(color: customColors.borderColor),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // مقدمة
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.handshake,
                        title: 'التزامنا بالخصوصية',
                        content: '''في BAHJA، نلتزم بحماية خصوصيتك وبياناتك الشخصية. نحن نقدر ثقتك بنا ونعمل بجد للحفاظ على أمان معلوماتك أثناء استخدامك لتطبيقنا لحجز خدمات الحفلات والمناسبات في اليمن.

هذه السياسة توضح كيفية جمع واستخدام وحماية بياناتك الشخصية.''',
                        theme: theme,
                        delay: 200,
                      ),

                      // البيانات المجمعة
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.database,
                        title: 'البيانات التي نجمعها',
                        content: '''نقوم بجمع البيانات التالية لتحسين خدماتنا:

• معلومات الحساب: الاسم، رقم الهاتف، البريد الإلكتروني
• معلومات الحجز: تفاصيل المناسبات والحفلات المحجوزة
• المعلومات الجغرافية: الموقع لتقديم خدمات محلية
• معلومات الجهاز: نوع الجهاز ونظام التشغيل
• سجل الاستخدام: كيفية تفاعلك مع التطبيق''',
                        theme: theme,
                        delay: 400,
                      ),

                      // استخدام البيانات
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.cogs,
                        title: 'كيف نستخدم بياناتك',
                        content: '''نستخدم بياناتك للأغراض التالية:

🎉 تنفيذ وإدارة حجوزات المناسبات والحفلات
📱 تحسين تجربة استخدام التطبيق
📧 إرسال إشعارات مهمة حول حجوزاتك
🎯 تقديم خدمات مخصصة حسب احتياجاتك
🛡️ ضمان أمان التطبيق ومنع الاحتيال
📊 تحليل استخدام التطبيق لتطوير خدمات أفضل''',
                        theme: theme,
                        delay: 600,
                      ),

                      // حماية البيانات
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.lock,
                        title: 'حماية بياناتك',
                        content: '''نطبق أعلى معايير الأمان لحماية بياناتك:

🔒 تشفير جميع البيانات أثناء النقل والتخزين
🛡️ خوادم آمنة مع حماية متقدمة من الاختراق
👥 تقييد الوصول للبيانات للموظفين المصرح لهم فقط
🔄 نسخ احتياطية منتظمة لضمان عدم فقدان البيانات
⚡ مراقبة مستمرة للأنشطة المشبوهة''',
                        theme: theme,
                        delay: 800,
                      ),

                      // مشاركة البيانات
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.shareAlt,
                        title: 'مشاركة البيانات',
                        content: '''نحن لا نبيع أو نؤجر بياناتك الشخصية لأطراف ثالثة. قد نشارك المعلومات فقط في الحالات التالية:

• مع مقدمي الخدمات المعتمدين لتنفيذ حجوزاتك
• عند وجود إلزام قانوني من السلطات المختصة
• لحماية حقوقنا وحقوق المستخدمين الآخرين
• مع موافقتك الصريحة المسبقة''',
                        theme: theme,
                        delay: 1000,
                      ),

                      // حقوق المستخدم
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.userShield,
                        title: 'حقوقك',
                        content: '''لديك الحقوق التالية فيما يتعلق ببياناتك:

✅ الحصول على نسخة من بياناتك الشخصية
✏️ تحديث أو تصحيح بياناتك
🗑️ طلب حذف حسابك وبياناتك
⛔ إيقاف معالجة بياناتك لأغراض معينة
📤 نقل بياناتك لخدمة أخرى
🚫 الاعتراض على معالجة بياناتك

للاستفادة من هذه الحقوق، تواصل معنا عبر خدمة العملاء.''',
                        theme: theme,
                        delay: 1200,
                      ),

                      // تحديث السياسة
                      _buildPrivacyCard(
                        icon: FontAwesomeIcons.sync,
                        title: 'تحديث السياسة',
                        content: '''قد نقوم بتحديث هذه السياسة من وقت لآخر لتعكس التغييرات في خدماتنا أو المتطلبات القانونية. سنقوم بإشعارك بأي تغييرات مهمة عبر التطبيق أو البريد الإلكتروني.

تاريخ آخر تحديث: ديسمبر 2024''',
                        theme: theme,
                        delay: 1400,
                      ),

                      // زر التواصل
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ContactUsPage()),
                            );
                          },
                          icon: FaIcon(FontAwesomeIcons.headset, size: 18),
                          label: Text(
                            'لديك أسئلة؟ تواصل معنا',
                            style: AppTextStyles.medium(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard({
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
    required int delay,
  }) {
    final customColors = AppThemes.customColors(context);
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: customColors.borderColor),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(
                              icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        content,
                        style: AppTextStyles.small(context).copyWith(
                          // color: theme.textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// رسام مخصص لتأثير الاحتفال
class CelebrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // رسم نقاط عشوائية تشبه البالونات والاحتفال
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 43) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    // رسم أشكال هندسية للاحتفال
    final trianglePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final x = (i * 71) % size.width;
      final y = (i * 53) % size.height;
      
      final path = Path();
      path.moveTo(x, y);
      path.lineTo(x + 10, y + 15);
      path.lineTo(x - 10, y + 15);
      path.close();
      
      canvas.drawPath(path, trianglePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}