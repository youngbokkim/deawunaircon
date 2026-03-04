import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estimate_provider.dart';
import '../utils/app_theme.dart';
import 'estimate_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A5F), Color(0xFF2C5282), Color(0xFF3D5A80)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 영역
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.ac_unit_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 회사명
                  const Text(
                    '대운공조시스템',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 부제목
                  Text(
                    '에어컨 견적서 관리 프로그램',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 메인 버튼들
                  _buildMainButton(
                    context,
                    icon: Icons.add_circle_outline,
                    title: '새 견적서 작성',
                    subtitle: '새로운 견적서를 작성합니다',
                    onTap: () {
                      context.read<EstimateProvider>().createNewEstimate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EstimateFormScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildMainButton(
                    context,
                    icon: Icons.folder_open_outlined,
                    title: '견적서 목록',
                    subtitle: '저장된 견적서를 확인합니다',
                    onTap: () {
                      _showEstimateList(context);
                    },
                  ),
                  const SizedBox(height: 48),

                  // 회사 정보
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          '경기도 하남시 감이남로66-2',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.phone_outlined, '02-483-4148'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.phone_android_outlined,
                          '010-5484-3315',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.email_outlined, 'hituch@naver.com'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: AppTheme.accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  void _showEstimateList(BuildContext context) {
    final provider = context.read<EstimateProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '저장된 견적서',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: provider.estimates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '저장된 견적서가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.estimates.length,
                      itemBuilder: (context, index) {
                        final estimate = provider.estimates[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: AppTheme.accentColor,
                              ),
                            ),
                            title: Text(
                              estimate.projectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '작성일: ${estimate.estimateDate.toString().substring(0, 10)}',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              provider.setCurrentEstimate(estimate);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EstimateFormScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

