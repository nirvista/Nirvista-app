import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';
import '../appbarcode.dart';
import '../drawercode.dart';

class TokenStackingPage extends StatefulWidget {
  const TokenStackingPage({super.key});

  @override
  State<TokenStackingPage> createState() => _TokenStackingPageState();
}

class _TokenStackingPageState extends State<TokenStackingPage> {
  final DrawerControllerr _drawerController = Get.put(DrawerControllerr());
  ColorNotifire notifire = ColorNotifire();
  final TextEditingController amountController =
      TextEditingController(text: '1000');
  final FocusNode _amountFocusNode = FocusNode();
  final TextInputFormatter _amountFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  bool isLoading = true;
  bool isSubmitting = false;
  String? apiError;
  String? processingWithdrawalId;
  String? processingClaimId;

  double minStakeTokens = 100;
  double amountToStack = 1000;
  double? totalBalance;
  double totalStacked = 0;
  double availableRewards = 0;
  DateTime? nextRewardDate;

  String selectedStackType = 'fixed';
  int selectedDuration = 12;
  bool rulesAccepted = false;

  final List<int> durationOptions = const [3, 6, 12, 24];
  Map<String, Map<int, double>> planRates = {
    'fixed': {3: 6, 6: 8, 12: 10, 24: 16},
    'fluid': {3: 3, 6: 6, 12: 8, 24: 10},
  };
  List<StakingPosition> stakes = [];

  @override
  void initState() {
    super.initState();
    _drawerController.colorSelecter(value: 21);
    amountController.addListener(_syncAmount);
    _loadData();
  }

  @override
  void dispose() {
    amountController
      ..removeListener(_syncAmount)
      ..dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _syncAmount() {
    final sanitized = amountController.text.replaceAll(',', '');
    final parsed = double.tryParse(sanitized);
    if (parsed != null) {
      amountToStack = parsed;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      apiError = null;
    });
    await _fetchAnalytics();
    await _fetchSummary();
    await _fetchStakes();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAnalytics() async {
    try {
      final response = await AuthApiService.getWalletAnalytics();
      if (response['success'] == true) {
        final data = _unwrap(response);
        final rawPlans = data['stackingPlans'] ??
            data['stacking_plans'] ??
            data['plans'] ??
            [];
        final updatedRates = {
          'fixed': Map<int, double>.from(planRates['fixed']!),
          'fluid': Map<int, double>.from(planRates['fluid']!),
        };
        if (rawPlans is List) {
          for (final plan in rawPlans) {
            if (plan is Map<String, dynamic>) {
              final type = (plan['stackType'] ??
                      plan['stack_type'] ??
                      plan['type'] ??
                      'fixed')
                  .toString()
                  .toLowerCase();
              final durationRaw = plan['durationMonths'] ??
                  plan['duration_months'] ??
                  plan['duration'];
              final rateRaw = plan['monthlyInterestRate'] ??
                  plan['interestRate'] ??
                  plan['monthlyRate'];
              final duration = durationRaw is num
                  ? durationRaw.toInt()
                  : int.tryParse('$durationRaw');
              final rate = rateRaw is num
                  ? rateRaw.toDouble()
                  : double.tryParse('$rateRaw');
              if (duration != null && rate != null) {
                final key = updatedRates.containsKey(type) ? type : 'fixed';
                updatedRates[key] = {
                  ...updatedRates[key]!,
                  duration: rate,
                };
              }
            }
          }
        }
        final minStake = data['minStakeTokens'] ??
            data['min_stake_tokens'] ??
            data['minimumStakeTokens'] ??
            data['minimum_stake_tokens'];
        setState(() {
          planRates = updatedRates;
          if (minStake is num) {
            minStakeTokens = minStake.toDouble();
          } else if (minStake is String) {
            minStakeTokens = double.tryParse(minStake) ?? minStakeTokens;
          }
          final availableDurations =
              planRates[selectedStackType]?.keys.toList() ?? [];
          if (!availableDurations.contains(selectedDuration) &&
              availableDurations.isNotEmpty) {
            selectedDuration = availableDurations.first;
          }
        });
      }
    } catch (_) {
      setState(() {
        apiError = 'Unable to load stacking plans.';
      });
    }
  }

  Future<void> _fetchSummary() async {
    try {
      final response = await AuthApiService.getWalletSummary();
      if (response['success'] == true) {
        final data = _unwrap(response);
        final balance = _extractNumber(data, [
          'totalBalance',
          'total_balance',
          'availableBalance',
          'available_balance',
          'walletBalance',
          'wallet_balance',
        ]);
        if (balance != null) {
          setState(() {
            totalBalance = balance;
          });
        }
      }
    } catch (_) {
      setState(() {
        apiError = 'Unable to load wallet summary.';
      });
    }
  }

  Future<void> _fetchStakes() async {
    try {
      final response = await AuthApiService.getWalletStakes();
      if (response['success'] == true) {
        final payload = response['data'];
        final entries = <Map<String, dynamic>>[];
        if (payload is List) {
          for (final entry in payload) {
            if (entry is Map<String, dynamic>) entries.add(entry);
          }
        } else if (payload is Map<String, dynamic>) {
          if (payload['stakes'] is List) {
            for (final entry in payload['stakes']) {
              if (entry is Map<String, dynamic>) entries.add(entry);
            }
          } else {
            entries.add(payload);
          }
        }
        final parsed = entries.map(StakingPosition.fromJson).toList();
        setState(() {
          stakes = parsed;
          totalStacked =
              stakes.fold(0, (sum, stake) => sum + stake.tokenAmount);
          availableRewards = stakes.fold(
            0,
            (sum, stake) => sum + stake.withdrawableInterest,
          );
          nextRewardDate = stakes
              .map((entry) => entry.nextInterestCreditAt ?? entry.startDate)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (prev, current) {
                  if (prev == null) return current;
                  return prev.isBefore(current) ? prev : current;
                },
              );
        });
      }
    } catch (_) {
      setState(() {
        apiError = 'Unable to load stakes.';
      });
    }
  }

  double? _planRateFor(String type, int duration) {
    final normalized = planRates[type.toLowerCase()] ?? planRates['fixed'];
    return normalized?[duration] ?? normalized?.values.first;
  }

  double get _monthlyInterest =>
      (amountToStack * (_planRateFor(selectedStackType, selectedDuration) ?? 0)) /
      100;

  double get _totalEstimatedInterest =>
      _monthlyInterest * selectedDuration.toDouble();

  bool get _canStartStack =>
      amountToStack >= minStakeTokens && rulesAccepted && !isSubmitting;

  Future<void> _startStake() async {
    if (!_canStartStack) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Stack'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are starting a $selectedDuration-month ${selectedStackType.toUpperCase()} stack.',
              ),
              const SizedBox(height: 8),
              Text('Amount: ${amountToStack.toStringAsFixed(0)} tokens'),
              Text(
                'Monthly Return: ${(_planRateFor(selectedStackType, selectedDuration) ?? 0).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 8),
              Text(
                selectedStackType == 'fixed'
                    ? 'Funds locked until maturity.'
                    : '1-month notice required.',
                style: TextStyle(
                  color: selectedStackType == 'fixed'
                      ? Colors.red
                      : Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _createStake();
    }
  }

  Future<void> _createStake() async {
    setState(() {
      isSubmitting = true;
      apiError = null;
    });
    try {
      final response = await AuthApiService.createStake(
        tokenAmount: amountToStack,
        stackType: selectedStackType,
        durationMonths: selectedDuration,
      );
      if (response['success'] == true) {
        final data = _unwrap(response);
        final holding = data['holding'];
        if (holding is Map<String, dynamic>) {
          final balance = _extractNumber(holding, ['balance', 'walletBalance']);
          if (balance != null) totalBalance = balance;
        }
        await _fetchStakes();
        _showSnackBar('Stack started successfully.');
      } else {
        _showSnackBar(
          response['message']?.toString() ?? 'Unable to start stack.',
          isError: true,
        );
      }
    } catch (error) {
      _showSnackBar('Failed to start stack. ${error.toString()}', isError: true);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _requestWithdrawal(StakingPosition stake) async {
    if (processingWithdrawalId != null) return;
    setState(() {
      processingWithdrawalId = stake.id;
    });
    try {
      final response =
          await AuthApiService.withdrawStake(stakeId: stake.id);
      if (response['success'] == true) {
        await _fetchStakes();
        _showSnackBar('Withdrawal notice requested.');
      } else {
        _showSnackBar(
          response['message']?.toString() ?? 'Unable to request withdrawal.',
          isError: true,
        );
      }
    } catch (error) {
      _showSnackBar('Withdrawal failed. ${error.toString()}', isError: true);
    } finally {
      setState(() {
        processingWithdrawalId = null;
      });
    }
  }

  Future<void> _claimStake(StakingPosition stake) async {
    if (processingClaimId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim Stack'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stack: ${stake.stackType.toUpperCase()}'),
            Text('Duration: ${stake.durationMonths} months'),
            Text('Amount: ${stake.tokenAmount.toStringAsFixed(0)} tokens'),
            Text(
                'Expected return: ${stake.expectedReturn.toStringAsFixed(0)} tokens'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Claim'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      processingClaimId = stake.id;
    });
    try {
      final response = await AuthApiService.claimStake(stakeId: stake.id);
      if (response['success'] == true) {
        final data = _unwrap(response);
        final holding = data['holding'];
        if (holding is Map<String, dynamic>) {
          final balance = _extractNumber(holding, ['balance', 'walletBalance']);
          if (balance != null) totalBalance = balance;
        }
        await _fetchStakes();
        _showSnackBar('Stack claimed successfully.');
      } else {
        _showSnackBar(
          response['message']?.toString() ?? 'Unable to claim stack.',
          isError: true,
        );
      }
    } catch (error) {
      _showSnackBar('Claim failed. ${error.toString()}', isError: true);
    } finally {
      setState(() {
        processingClaimId = null;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  void _setMaxAmount() {
    final maxAvailable = (totalBalance ?? amountToStack).clamp(
      minStakeTokens,
      double.infinity,
    );
    amountController.text = maxAvailable.toStringAsFixed(0);
  }

  void _focusAmountInput() {
    FocusScope.of(context).requestFocus(_amountFocusNode);
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    return response;
  }

  double? _extractNumber(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _formatTokens(double value) {
    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final withCommas = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    return '$withCommas${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  String _countdown(DateTime? target) {
    if (target == null) return '�';
    final difference = target.difference(DateTime.now());
    if (difference.isNegative) return 'Now';
    if (difference.inDays >= 1) return 'In ${difference.inDays} days';
    if (difference.inHours >= 1) return 'In ${difference.inHours} hrs';
    return 'Soon';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '�';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSummaryActions() {
    return Row(
      children: [
        ElevatedButton(
          style: _summaryWithdrawButtonStyle,
          onPressed: availableRewards > 0
              ? () => _showSnackBar('Reward withdraw feature coming soon.')
              : null,
          child: Text(
            'Withdraw Rewards',
            style: Typographyy.bodyMediumMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2CD6C1),
                  Color(0xFF0BB4A6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 30,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: _focusAmountInput,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: Text(
                  'Start New Stack',
                  style: Typographyy.bodyLargeMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle get _summaryWithdrawButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF6C25F),
      foregroundColor: Colors.black,
      disabledBackgroundColor: const Color(0xFFF6C25F).withOpacity(0.5),
      disabledForegroundColor: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.25),
    ).copyWith(
      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.35)),
    );
  }

  Widget _buildBody(BoxConstraints constraints) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: priMeryColor),
      );
    }
    final padding = constraints.maxWidth < 900 ? 16.0 : 32.0;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apiError != null) _buildErrorBanner(),
            _buildTopSummary(),
            const SizedBox(height: 24),
            _buildSelectors(constraints.maxWidth < 900),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildRules(),
            const SizedBox(height: 12),
            _buildAgreement(),
            const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 32),
            _buildStacks(),
            const SizedBox(height: 32),
            _buildNotifications(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        apiError ?? '',
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildTopSummary() {
    final balanceText =
        totalBalance != null ? _formatTokens(totalBalance!) : '� tokens';
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F8C7E),
            Color(0xFF0B1A3D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 14),
            blurRadius: 35,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Main Stacking Dashboard',
            style: Typographyy.heading5.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                title: 'Total Balance',
                value: balanceText,
                background: Colors.white.withOpacity(0.15),
                textColor: Colors.white,
              ),
              _MetricCard(
                title: 'Total Stacked',
                value: _formatTokens(totalStacked),
                background: Colors.white.withOpacity(0.15),
                textColor: Colors.white,
              ),
              _MetricCard(
                title: 'Available Rewards',
                value: _formatTokens(availableRewards),
                detail: '(withdrawable)',
                background: Colors.white.withOpacity(0.15),
                textColor: Colors.white,
              ),
              _MetricCard(
                title: 'Next Reward',
                value: _countdown(nextRewardDate),
                detail: 'countdown',
                background: Colors.white.withOpacity(0.15),
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryActions(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        final content = _buildBody(constraints);
        if (isMobile) {
          return Scaffold(
            backgroundColor: notifire.getBgColor,
            drawer: const DrawerCode(),
            appBar: const AppBarCode(),
            body: content,
          );
        }
        return Scaffold(
          backgroundColor: notifire.getBgColor,
          body: Row(
            children: [
              const DrawerCode(),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildSelectors(bool isMobile) {
    final stackTypeChooser = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStackTypeCard('fixed'),
              const SizedBox(height: 12),
              _buildStackTypeCard('fluid'),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildStackTypeCard('fixed')),
              const SizedBox(width: 12),
              Expanded(child: _buildStackTypeCard('fluid')),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notifire.getContainerColor.withOpacity(0.95),
            notifire.getContainerColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: notifire.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stackTypeChooser,
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: durationOptions.map(_buildDurationChip).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildReturnsPreview(),
        ],
      ),
    );
  }

  Widget _buildStackTypeCard(String type) {
    final isFixed = type == 'fixed';
    final isSelected = selectedStackType == type;
    final accent = isFixed ? Colors.redAccent : Colors.blueAccent;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStackType = type;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.12)
              : notifire.getContainerColor2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : notifire.getBorderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isFixed ? 'FIXED STACK' : 'FLUID STACK',
                  style: Typographyy.bodyLargeMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: notifire.getTextColor,
                  ),
                ),
                const Spacer(),
                if (isFixed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Recommended',
                      style: Typographyy.bodySmallMedium.copyWith(
                        fontSize: 10,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isFixed ? 'Higher returns' : 'Flexible withdrawal',
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getGry600_500Color),
            ),
            const SizedBox(height: 8),
            Text(
              isFixed ? 'Locked until maturity' : '1-month notice required',
              style: Typographyy.bodySmallRegular
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            const SizedBox(height: 8),
            Text(
              isSelected ? 'Selected' : 'Tap to select',
              style: Typographyy.bodySmallRegular.copyWith(
                color: isSelected ? accent : notifire.getGry500_600Color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int months) {
    final isActive = selectedDuration == months;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDuration = months;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? priMeryColor.withOpacity(0.1)
                : notifire.getContainerColor2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? priMeryColor : notifire.getBorderColor,
            ),
          ),
          child: Text(
            '$months Months',
            style: Typographyy.bodyLargeMedium.copyWith(
              color: isActive ? priMeryColor : notifire.getTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnsPreview() {
    final fluidRates = planRates['fluid'] ?? const {};
    final fixedRates = planRates['fixed'] ?? const {};
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notifire.getContainerColor.withOpacity(0.9),
            notifire.getContainerColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notifire.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildReturnColumn('Fluid Stack Returns', fluidRates),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildReturnColumn(
              'Fixed Stack Returns',
              fixedRates,
              highlight24: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnColumn(String title, Map<int, double> rates,
      {bool highlight24 = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 12),
        ...durationOptions.map((months) {
          final rate = rates[months] ??
              _planRateFor(title.contains('Fixed') ? 'fixed' : 'fluid', months) ??
              0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: notifire.getBorderColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$months mo',
                        style: Typographyy.bodySmallRegular.copyWith(
                            color: notifire.getTextColor),
                      ),
                    ),
                    if (highlight24 && months == 24)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          'Best return',
                          style: Typographyy.bodySmallMedium
                              .copyWith(color: priMeryColor),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${rate.toStringAsFixed(1)}% / mo',
                    style: Typographyy.bodyLargeMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: notifire.getTextColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Container(
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notifire.getBorderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount to Stack',
            style: Typographyy.bodyLargeMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  focusNode: _amountFocusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_amountFormatter],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: notifire.getBorderColor),
                    ),
                    hintText: '1,000',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _setMaxAmount,
                child: const Text('MAX'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estimated Monthly Interest: +${_monthlyInterest.toStringAsFixed(0)} tokens',
            style: Typographyy.bodyLargeMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Total Estimated Earnings: +${_totalEstimatedInterest.toStringAsFixed(0)} tokens',
            style: Typographyy.bodyLargeMedium,
          ),
          const SizedBox(height: 12),
          const Text(
              'Updates in real time based on stack type, duration, and amount.'),
        ],
      ),
    );
  }

  Widget _buildRules() {
    return Row(
      children: [
        Expanded(
          child: _RuleCard(
            title: 'Fixed Stack Rules',
            accent: Colors.red,
            items: const [
              'Higher monthly returns',
              'Interest credited every month',
              'Interest withdrawable after 30 days',
              'Principal locked until maturity',
              'Cannot cancel early',
            ],
            warning: 'Funds cannot be withdrawn until maturity.',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RuleCard(
            title: 'Fluid Stack Rules',
            accent: Colors.blue,
            items: const [
              'Interest withdrawable every 30 days',
              'Principal requires 1-month notice',
              'Stack can be cancelled',
            ],
            warning: 'Withdrawable after notice period.',
          ),
        ),
      ],
    );
  }

  Widget _buildAgreement() {
    return Row(
      children: [
        Checkbox(
          value: rulesAccepted,
          onChanged: (value) {
            setState(() {
              rulesAccepted = value ?? false;
            });
          },
        ),
        const Expanded(
          child: Text('I understand the lock & withdrawal rules'),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final tooltip = !_canStartStack
        ? 'Amount must be >= ${minStakeTokens.toStringAsFixed(0)} tokens and agree to rules.'
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: _canStartStack ? '' : tooltip,
          child: ElevatedButton(
            style: _stackPrimaryButtonStyle,
            onPressed: _canStartStack ? _startStake : null,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Start Stack'),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedStackType == 'fluid')
          OutlinedButton(
            style: _stackSecondaryButtonStyle,
            onPressed: () {
              setState(() {
                amountController.clear();
                amountToStack = 0;
                rulesAccepted = false;
              });
            },
            child: const Text('Cancel Stack'),
          ),
      ],
    );
  }

  ButtonStyle get _stackPrimaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: priMeryColor,
      disabledBackgroundColor: priMeryColor.withOpacity(0.55),
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      shadowColor: priMeryColor.withOpacity(0.45),
    ).copyWith(
      overlayColor:
          MaterialStateProperty.all(Colors.white.withOpacity(0.15)),
    );
  }

  ButtonStyle get _stackSecondaryButtonStyle {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: priMeryColor.withOpacity(0.85), width: 1.3),
      foregroundColor: priMeryColor,
      disabledForegroundColor: priMeryColor.withOpacity(0.35),
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.pressed)
            ? priMeryColor.withOpacity(0.12)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildStacks() {
    if (stakes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notifire.getContainerColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: notifire.getBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.pie_chart, size: 32),
            const SizedBox(height: 12),
            const Text('📈 Start stacking your tokens'),
            const Text('Earn monthly interest automatically.'),
            const SizedBox(height: 12),
            ElevatedButton(
              style: _stackPrimaryButtonStyle,
              onPressed: _focusAmountInput,
              child: const Text('Start Stack'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stakes.map(_buildStakeCard).toList(),
    );
  }

  Widget _buildStakeCard(StakingPosition stake) {
    final withdrawable = stake.withdrawal?['withdrawableAt'];
    DateTime? withdrawableAt;
    if (withdrawable is String) {
      withdrawableAt = DateTime.tryParse(withdrawable);
    } else if (withdrawable is DateTime) {
      withdrawableAt = withdrawable;
    }
    final isFluid = stake.stackType.toLowerCase() == 'fluid';
    final canRequestWithdrawal =
        isFluid && stake.withdrawal == null && processingWithdrawalId == null;
    final canClaim = stake.status.toLowerCase() == 'matured' ||
        (withdrawableAt != null && withdrawableAt.isBefore(DateTime.now()));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notifire.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${stake.stackType.toUpperCase()} STACK – ${stake.durationMonths} Months',
                style: Typographyy.heading6.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priMeryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stake.status,
                  style: Typographyy.bodyLargeMedium.copyWith(
                    color: priMeryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyValue(
                label: 'Amount',
                value: _formatTokens(stake.tokenAmount),
              ),
              _KeyValue(
                label: 'Monthly Return',
                value: '${stake.interestRate.toStringAsFixed(1)}% / month',
                tooltip:
                    'Interest locked for ${stake.durationMonths} months.',
              ),
              _KeyValue(
                label: 'Interest Earned',
                value: '${stake.interestEarned.toStringAsFixed(0)} tokens',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressRing(progress: stake.progress),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KeyValue(
                label: 'Start Date',
                value: _formatDate(stake.startDate),
              ),
              _KeyValue(
                label: 'Maturity',
                value: _formatDate(stake.endDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Next interest credit: ${_countdown(stake.nextInterestCreditAt)}',
            style: Typographyy.bodyMediumMedium,
          ),
          if (withdrawableAt != null)
            Text(
              'Withdrawal available ${_countdown(withdrawableAt)}',
              style: Typographyy.bodyMediumMedium,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: canRequestWithdrawal
                    ? () => _requestWithdrawal(stake)
                    : null,
                child: processingWithdrawalId == stake.id
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Request Withdrawal'),
              ),
              const SizedBox(width: 12),
              if (canClaim)
                ElevatedButton(
                  onPressed: processingClaimId == stake.id
                      ? null
                      : () => _claimStake(stake),
                  child: processingClaimId == stake.id
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Claim'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InterestHistory(entries: stake.interestHistory),
          const SizedBox(height: 12),
          _TransactionDetails(stake: stake, formatDate: _formatDate),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    final notifications = [
      '🎉 Your monthly interest is available',
      '⏳ Withdrawal available in 3 days',
      '🔔 Your Fixed stack matures today',
    ];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notifire.getBorderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notifications
            .map(
              (note) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  note,
                  style: Typographyy.bodyLargeMedium,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    this.detail,
    this.background,
    this.textColor,
  });

  final String title;
  final String value;
  final String? detail;
  final Color? background;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    final valueColor = textColor ?? notifire.getTextColor;
    final titleColor = textColor ?? notifire.getGry600_500Color;
    final cardColor = background ?? notifire.getContainerColor;
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifire.getBorderColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Typographyy.bodySmallMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Typographyy.heading6.copyWith(fontSize: 20, color: valueColor),
            ),
            if (detail != null)
              Text(
                detail!,
                style: Typographyy.bodySmallMedium
                    .copyWith(color: Colors.grey.shade300),
              ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.title,
    required this.accent,
    required this.items,
    required this.warning,
  });

  final String title;
  final Color accent;
  final List<String> items;
  final String warning;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    return Container(
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Typographyy.bodyLargeMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Typographyy.bodySmallRegular,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            warning,
            style: Typographyy.bodySmallMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value, this.tooltip});

  final String label;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    final child = Text(
      value,
      style: Typographyy.bodyLargeMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: notifire.getTextColor,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Typographyy.bodySmallMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(height: 4),
        if (tooltip != null)
          Tooltip(message: tooltip!, child: child)
        else
          child,
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                color: priMeryColor,
                backgroundColor: notifire.getBorderColor,
              ),
            ),
            Text('${(progress * 100).round()}%'),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: priMeryColor,
            backgroundColor: notifire.getBorderColor,
          ),
        ),
      ],
    );
  }
}

class _InterestHistory extends StatelessWidget {
  const _InterestHistory({required this.entries});

  final List<InterestEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Interest History',
          style: Typographyy.bodyLargeMedium,
        ),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
              '${entry.label} – ${entry.amount.toStringAsFixed(0)} tokens',
                  style: Typographyy.bodyMediumMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.status == 'Available'
                        ? Colors.green.shade100
                        : entry.status == 'Pending'
                            ? Colors.orange.shade100
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.status,
                    style: Typographyy.bodySmallMedium,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({
    required this.stake,
    required this.formatDate,
  });

  final StakingPosition stake;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Details',
          style: Typographyy.bodyLargeMedium.copyWith(
            color: notifire.getTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text('Transaction ID: ${stake.transactionId ?? '�'}'),
        Text('Status: ${stake.status}'),
        Text('Duration: ${stake.durationMonths} Months'),
        Text(
          'Network Fee: ${stake.networkFee?.toStringAsFixed(2) ?? '�'} tokens',
        ),
      ],
    );
  }
}

class StakingPosition {
  StakingPosition({
    required this.id,
    required this.stackType,
    required this.tokenAmount,
    required this.durationMonths,
    required this.interestRate,
    required this.expectedReturn,
    required this.interestEarned,
    required this.withdrawableInterest,
    required this.status,
    this.startDate,
    this.endDate,
    this.nextInterestCreditAt,
    this.withdrawal,
    required this.interestHistory,
    this.transactionId,
    this.networkFee,
  });

  final String id;
  final String stackType;
  final double tokenAmount;
  final int durationMonths;
  final double interestRate;
  final double expectedReturn;
  final double interestEarned;
  final double withdrawableInterest;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextInterestCreditAt;
  final Map<String, dynamic>? withdrawal;
  final List<InterestEntry> interestHistory;
  final String? transactionId;
  final double? networkFee;

  double get progress {
    if (startDate == null || endDate == null) return 0;
    final duration = endDate!.difference(startDate!).inMilliseconds;
    if (duration <= 0) return 0;
    final elapsed = DateTime.now().difference(startDate!).inMilliseconds;
    return (elapsed / duration).clamp(0, 1).toDouble();
  }

  factory StakingPosition.fromJson(Map<String, dynamic> json) {
    final historyRaw = json['interestHistory'] ?? json['interest_history'];
    final history = <InterestEntry>[];
    if (historyRaw is List) {
      for (final entry in historyRaw) {
        if (entry is Map<String, dynamic>) {
          history.add(InterestEntry.fromJson(entry));
        }
      }
    }
    return StakingPosition(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      stackType: json['stackType'] ?? json['stack_type'] ?? 'fixed',
      tokenAmount:
          _toDouble(json['tokenAmount'] ?? json['token_amount'] ?? 0),
      durationMonths:
          (json['durationMonths'] ?? json['duration_months'] ?? 0).toInt(),
      interestRate: _toDouble(
          json['interestRate'] ?? json['monthlyInterestRate'] ?? 0),
      expectedReturn:
          _toDouble(json['expectedReturn'] ?? json['expected_return'] ?? 0),
      interestEarned:
          _toDouble(json['interestEarned'] ?? json['interest_earned'] ?? 0),
      withdrawableInterest: _toDouble(
        json['withdrawableInterest'] ??
            json['withdrawable_interest'] ??
            json['withdrawable'] ??
            0,
      ),
      status: json['status']?.toString() ?? 'Active',
      startDate: _parseDate(json['startDate'] ?? json['createdAt'] ?? json['startedAt']),
      endDate: _parseDate(json['endDate'] ?? json['maturityDate'] ?? json['end_date']),
      nextInterestCreditAt:
          _parseDate(json['nextInterestCreditAt'] ?? json['nextInterestDate']),
      withdrawal: json['withdrawal'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['withdrawal'])
          : null,
      interestHistory: history,
      transactionId: json['transactionId'] ?? json['txId'],
      networkFee: _toDouble(json['networkFee'] ?? json['network_fee']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class InterestEntry {
  InterestEntry({
    required this.label,
    required this.amount,
    required this.status,
  });

  final String label;
  final double amount;
  final String status;

  factory InterestEntry.fromJson(Map<String, dynamic> json) {
    return InterestEntry(
      label: json['label'] ??
          json['month'] ??
          json['period'] ??
          'Interest',
      amount: StakingPosition._toDouble(json['amount'] ?? json['value'] ?? 0),
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}
