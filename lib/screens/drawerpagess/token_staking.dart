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

class TokenStakingPage extends StatefulWidget {
  const TokenStakingPage({super.key});

  @override
  State<TokenStakingPage> createState() => _TokenStakingPageState();
}

class _TokenStakingPageState extends State<TokenStakingPage> {
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
  double amountToStake = 1000;
  double? totalBalance;
  double totalStaked = 0;
  double availableRewards = 0;
  DateTime? nextRewardDate;

  String selectedStakeType = 'fixed';
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
    _drawerController.colorSelecter(
      value: DrawerControllerr.tokenStakingColorIndex,
    );
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
      amountToStake = parsed;
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
              planRates[selectedStakeType]?.keys.toList() ?? [];
          if (!availableDurations.contains(selectedDuration) &&
              availableDurations.isNotEmpty) {
            selectedDuration = availableDurations.first;
          }
        });
      }
    } catch (_) {
      setState(() {
        apiError = 'Unable to load staking plans.';
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
          totalStaked = stakes.fold(0, (sum, stake) => sum + stake.tokenAmount);
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
      (amountToStake *
          (_planRateFor(selectedStakeType, selectedDuration) ?? 0)) /
      100;

  double get _totalEstimatedInterest =>
      _monthlyInterest * selectedDuration.toDouble();

  bool get _canStartStake =>
      amountToStake >= minStakeTokens && rulesAccepted && !isSubmitting;

  Future<void> _startStake() async {
    if (!_canStartStake) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Stake'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are starting a $selectedDuration-month ${selectedStakeType.toUpperCase()} stake.',
              ),
              const SizedBox(height: 8),
              Text('Amount: ${amountToStake.toStringAsFixed(0)} tokens'),
              Text(
                'Monthly Return: ${(_planRateFor(selectedStakeType, selectedDuration) ?? 0).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 8),
              Text(
                selectedStakeType == 'fixed'
                    ? 'Funds locked until maturity.'
                    : '1-month notice required.',
                style: TextStyle(
                  color:
                      selectedStakeType == 'fixed' ? Colors.red : Colors.blue,
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
    final double capturedAmount = amountToStake;
    final String capturedStakeType = selectedStakeType;
    final int capturedDuration = selectedDuration;
    try {
      final response = await AuthApiService.createStake(
        tokenAmount: amountToStake,
        stackType: selectedStakeType,
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
        await _showStakingSuccessDialog(
          amount: capturedAmount,
          duration: capturedDuration,
          stackType: capturedStakeType,
        );
        _showSnackBar('Stake started successfully.');
      } else {
        _showSnackBar(
          response['message']?.toString() ?? 'Unable to start stake.',
          isError: true,
        );
      }
    } catch (error) {
      _showSnackBar('Failed to start stake. ${error.toString()}',
          isError: true);
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
      final response = await AuthApiService.withdrawStake(stakeId: stake.id);
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
        title: const Text('Claim Stake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stake: ${stake.stackType.toUpperCase()}'),
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
        _showSnackBar('Stake claimed successfully.');
      } else {
        _showSnackBar(
          response['message']?.toString() ?? 'Unable to Claim Stake.',
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

  Future<void> _showStakingSuccessDialog({
    required double amount,
    required int duration,
    required String stackType,
  }) async {
    if (!mounted) return;
    final stackLabel = stackType == 'fluid' ? 'Fluid Stake' : 'Fixed Stake';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staking Done'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$stackLabel â€¢ $duration months',
              style: Typographyy.bodyLargeMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: notifire.getTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text('Amount: ${_formatTokens(amount)} tokens'),
            const SizedBox(height: 8),
            Text(
              'Tokens on dashboard: ${_formatTokens(totalStaked)}',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            Text(
              'Rewards ready: ${_formatTokens(availableRewards)}',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _setMaxAmount() {
    final maxAvailable = (totalBalance ?? amountToStake).clamp(
      minStakeTokens,
      double.infinity,
    );
    amountController.text = maxAvailable.toStringAsFixed(0);
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
    final formatted =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final withCommas = parts[0]
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    return '$withCommas${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  String _countdown(DateTime? target) {
    if (target == null) return 'ï¿½';
    final difference = target.difference(DateTime.now());
    if (difference.isNegative) return 'Now';
    if (difference.inDays >= 1) return 'In ${difference.inDays} days';
    if (difference.inHours >= 1) return 'In ${difference.inHours} hrs';
    return 'Soon';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'ï¿½';
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
        Expanded(
          child: ElevatedButton(
            style: _summaryWithdrawButtonStyle,
            onPressed: availableRewards > 0
                ? () => _showSnackBar('Reward withdraw feature coming soon.')
                : null,
            child: Text(
              'Withdraw Rewards',
              style: Typographyy.bodyMediumMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: priMeryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle get _summaryWithdrawButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: priMeryColor,
      disabledBackgroundColor: Colors.white.withOpacity(0.8),
      disabledForegroundColor: priMeryColor.withOpacity(0.35),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: priMeryColor.withOpacity(0.2)),
      ),
      elevation: 2,
      shadowColor: priMeryColor.withOpacity(0.2),
    ).copyWith(
      overlayColor: MaterialStateProperty.all(priMeryColor.withOpacity(0.1)),
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
            _buildActiveStakeOverview(),
            const SizedBox(height: 24),
            _buildPlanCardsSection(constraints.maxWidth < 900),
            const SizedBox(height: 18),
            _buildPlanSelectionSection(),
            const SizedBox(height: 18),
            _buildAmountAndStartSection(),
            const SizedBox(height: 32),
            _buildStakeList(),
            const SizedBox(height: 32),
            _buildBenefitAndRulesSection(),
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
        totalBalance != null ? _formatTokens(totalBalance!) : 'ï¿½ tokens';
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
            'Main Staking Dashboard',
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
                title: 'Total Staked',
                value: _formatTokens(totalStaked),
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

  Widget _buildActiveStakeOverview() {
    if (stakes.isEmpty) return const SizedBox.shrink();
    final previewStakes = stakes.take(3).toList();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: notifire.getBorderColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Staked Tokens',
                style: Typographyy.heading5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: notifire.getTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: priMeryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stakes.length} stakes',
                  style: Typographyy.bodySmallMedium.copyWith(
                    color: priMeryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final stake in previewStakes)
                Chip(
                  backgroundColor: priMeryColor.withOpacity(0.15),
                  label: Text(
                    '${stake.stackType.toUpperCase()} ${stake.durationMonths}M • ${_formatTokens(stake.tokenAmount)}',
                    style: Typographyy.bodySmallRegular.copyWith(
                      color: priMeryColor,
                    ),
                  ),
                ),
              if (stakes.length > previewStakes.length)
                Chip(
                  backgroundColor: notifire.getBorderColor.withOpacity(0.2),
                  label: Text(
                    '+${stakes.length - previewStakes.length} more',
                    style: Typographyy.bodySmallRegular.copyWith(
                      color: notifire.getTextColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Tokens staked:',
                style: Typographyy.bodySmallMedium.copyWith(
                  color: notifire.getGry500_600Color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTokens(totalStaked),
                style: Typographyy.bodyLargeMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rewards ready: ${_formatTokens(availableRewards)}',
            style: Typographyy.bodyMediumMedium.copyWith(
              color: notifire.getGry500_600Color,
            ),
          ),
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

  Widget _buildPlanCardsSection(bool isMobile) {
    final titleStyle = Typographyy.heading5.copyWith(
      fontWeight: FontWeight.w700,
      color: notifire.getTextColor,
    );
    final descriptionStyle = Typographyy.bodyMediumMedium.copyWith(
      color: notifire.getGry500_600Color,
    );
    final cardGroup = isMobile
        ? Column(
            children: [
              _buildPlanCard(
                type: 'fixed',
                accentStart: const Color(0xFF2A6BCB),
                accentEnd: const Color(0xFF0B2A6F),
                icon: Icons.lock_clock,
                title: 'Fixed Stake',
                subtitle: 'Lock funds for predictable, higher yields.',
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                type: 'fluid',
                accentStart: const Color(0xFF25D9BE),
                accentEnd: const Color(0xFF0B5E52),
                icon: Icons.autorenew,
                title: 'Fluid Stake',
                subtitle: 'Withdraw with notice for extra flexibility.',
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPlanCard(
                  type: 'fixed',
                  accentStart: const Color(0xFF2A6BCB),
                  accentEnd: const Color(0xFF0B2A6F),
                  icon: Icons.lock_clock,
                  title: 'Fixed Stake',
                  subtitle: 'Lock funds for predictable, higher yields.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPlanCard(
                  type: 'fluid',
                  accentStart: const Color(0xFF25D9BE),
                  accentEnd: const Color(0xFF0B5E52),
                  icon: Icons.autorenew,
                  title: 'Fluid Stake',
                  subtitle: 'Withdraw with notice for extra flexibility.',
                ),
              ),
            ],
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stake Types', style: titleStyle),
        const SizedBox(height: 6),
        Text(
          'Choose the stake experience that matches your return vs. flexibility goals.',
          style: descriptionStyle,
        ),
        const SizedBox(height: 16),
        cardGroup,
      ],
    );
  }

  Widget _buildPlanSelectionSection() {
    final rate = _planRateFor(selectedStakeType, selectedDuration) ?? 0;
    final stackLabel =
        selectedStakeType == 'fluid' ? 'Fluid Stake' : 'Fixed Stake';
    final headerStyle = Typographyy.heading5.copyWith(
      fontWeight: FontWeight.w700,
      color: notifire.getTextColor,
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: priMeryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Staking Plan', style: headerStyle),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: priMeryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ICO',
                  style: Typographyy.bodySmallMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pick a duration to see the rate and earnings before you commit.',
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 16),
          _buildDurationChips(),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Selected rate:',
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
              const SizedBox(width: 8),
              Text(
                '${rate.toStringAsFixed(1)}% APR',
                style: Typographyy.bodyLargeMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: priMeryColor,
                ),
              ),
              const Spacer(),
              Text(
                '$stackLabel â€¢ $selectedDuration months',
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountAndStartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAmountSection(),
        const SizedBox(height: 12),
        _buildStartActionBox(),
      ],
    );
  }

  Widget _buildStartActionBox() {
    final ready = _canStartStake;
    final hintColor = ready ? priMeryColor : Colors.orange.shade700;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: priMeryColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to stake?',
            style: Typographyy.bodyLargeMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter an amount, accept the rules, and tap the box below to start staking.',
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 12),
          _buildAgreement(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: _stakeButtonStyle,
              onPressed: _canStartStake ? _startStake : null,
              child: const Text('Start Staking'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _stakeActionHint,
            style: Typographyy.bodySmallMedium.copyWith(
              color: hintColor,
            ),
          ),
        ],
      ),
    );
  }

  String get _stakeActionHint {
    if (amountToStake < minStakeTokens) {
      return 'Minimum stake is ${_formatTokens(minStakeTokens)} tokens.';
    }
    if (!rulesAccepted) {
      return 'Accept the lock & withdrawal rules to continue.';
    }
    return 'All set - tap "Start Staking" to lock your tokens.';
  }

  Widget _buildDurationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: durationOptions.map((duration) {
        final isActive = selectedDuration == duration;
        return ChoiceChip(
          label: Text('$duration Months'),
          selected: isActive,
          onSelected: (_) {
            setState(() {
              selectedDuration = duration;
            });
          },
          selectedColor: priMeryColor,
          backgroundColor: notifire.getContainerColor,
          labelStyle: Typographyy.bodySmallMedium.copyWith(
            color: isActive ? Colors.white : notifire.getTextColor,
          ),
        );
      }).toList(),
    );
  }

  void _selectPlan(String type) {
    final durations = planRates[type]?.keys.toList() ?? [];
    setState(() {
      selectedStakeType = type;
      if (!durations.contains(selectedDuration) && durations.isNotEmpty) {
        selectedDuration = durations.first;
      }
    });
  }

  Widget _buildPlanCard({
    required String type,
    required Color accentStart,
    required Color accentEnd,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedStakeType == type;
    final rates = planRates[type]?.entries.toList() ?? [];
    rates.sort((a, b) => a.key.compareTo(b.key));
    final bestRate = rates.fold<double>(
      0,
      (prev, current) => current.value > prev ? current.value : prev,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentStart, accentEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentEnd.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color:
              isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Typographyy.heading6.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Active',
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Typographyy.bodyMediumMedium
                .copyWith(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rates
                .map(
                  (entry) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.key}M â€¢ ${entry.value.toStringAsFixed(1)}%',
                      style: Typographyy.bodySmallRegular
                          .copyWith(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          ),
          if (rates.isEmpty)
            Text(
              'Plan information loading...',
              style:
                  Typographyy.bodySmallRegular.copyWith(color: Colors.white70),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best available rate',
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: Colors.white70),
                    ),
                    Text(
                      '${bestRate.toStringAsFixed(1)}% APR',
                      style: Typographyy.bodyLargeMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: _planSelectButtonStyle,
                onPressed: () => _selectPlan(type),
                child: Text(isSelected ? 'Plan Selected' : 'Choose Plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle get _planSelectButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: priMeryColor,
      elevation: 4,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.all(priMeryColor.withOpacity(0.12)),
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
            'Amount to Stake',
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
          const SizedBox(height: 8),
          Text(
            'Minimum stake: ${_formatTokens(minStakeTokens)} tokens',
            style: Typographyy.bodySmallMedium.copyWith(
              color: notifire.getGry500_600Color,
            ),
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
              'Updates in real time based on stake type, duration, and amount.'),
        ],
      ),
    );
  }

  Widget _buildBenefitAndRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Benefits & Rules',
              style: Typographyy.heading5.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10),
            Icon(Icons.shield, color: priMeryColor),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: notifire.getContainerColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: priMeryColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: priMeryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Review the rules before staking to keep your funds secure.',
                      style: Typographyy.bodyMediumMedium.copyWith(
                        color: notifire.getTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildBenefitHighlights(),
              const SizedBox(height: 24),
              _buildRules(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitHighlights() {
    return Row(
      children: [
        Expanded(
          child: _BenefitCard(
            title: 'Core Benefits',
            accent: priMeryColor,
            icon: Icons.auto_graph,
            items: const [
              'Monthly interest credited automatically',
              'Clear notifications for upcoming rewards',
              'Flexible Fluid Stake withdrawals with notice',
              'Built-in analytics to track progress',
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle get _stakeButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: priMeryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(54),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 8,
      shadowColor: priMeryColor.withOpacity(0.45),
    ).copyWith(
      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.18)),
    );
  }

  Widget _buildRules() {
    return Row(
      children: [
        Expanded(
          child: _RuleCard(
            title: 'Fixed Stake Rules',
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
            title: 'Fluid Stake Rules',
            accent: Colors.blue,
            items: const [
              'Interest withdrawable every 30 days',
              'Principal requires 1-month notice',
              'Stake can be cancelled',
            ],
            warning: 'Withdrawable after notice period.',
          ),
        ),
      ],
    );
  }

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: rulesAccepted,
          onChanged: (value) {
            setState(() {
              rulesAccepted = value ?? false;
            });
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'I understand the lock & withdrawal rules.',
            style: Typographyy.bodyLargeMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsentCTA() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: priMeryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgreement(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: _stakeButtonStyle,
              onPressed: _canStartStake ? _startStake : null,
              child: const Text('Understand & Start Stake'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStakeList() {
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
            const Text('ðŸ“ˆ Start staking your tokens'),
            const Text('Earn monthly interest automatically.'),
            const SizedBox(height: 12),
            Text(
              'Use the Start New Stake CTA above to begin staking.',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
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
                '${stake.stackType.toUpperCase()} STAKE â€“ ${stake.durationMonths} Months',
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
                tooltip: 'Interest locked for ${stake.durationMonths} months.',
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
      'ðŸŽ‰ Your monthly interest is available',
      'â³ Withdrawal available in 3 days',
      'ðŸ”” Your Fixed Stake matures today',
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
              style: Typographyy.heading6
                  .copyWith(fontSize: 20, color: valueColor),
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

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.title,
    required this.accent,
    required this.items,
    required this.icon,
  });

  final String title;
  final Color accent;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire = Provider.of<ColorNotifire>(context);
    return Container(
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 10),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: Typographyy.bodyLargeMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: notifire.getTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Typographyy.bodySmallRegular.copyWith(
                        color: notifire.getTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  '${entry.label} â€“ ${entry.amount.toStringAsFixed(0)} tokens',
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
        Text('Transaction ID: ${stake.transactionId ?? 'ï¿½'}'),
        Text('Status: ${stake.status}'),
        Text('Duration: ${stake.durationMonths} Months'),
        Text(
          'Network Fee: ${stake.networkFee?.toStringAsFixed(2) ?? 'ï¿½'} tokens',
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
      tokenAmount: _toDouble(json['tokenAmount'] ?? json['token_amount'] ?? 0),
      durationMonths:
          (json['durationMonths'] ?? json['duration_months'] ?? 0).toInt(),
      interestRate:
          _toDouble(json['interestRate'] ?? json['monthlyInterestRate'] ?? 0),
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
      startDate: _parseDate(
          json['startDate'] ?? json['createdAt'] ?? json['startedAt']),
      endDate: _parseDate(
          json['endDate'] ?? json['maturityDate'] ?? json['end_date']),
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
      label: json['label'] ?? json['month'] ?? json['period'] ?? 'Interest',
      amount: StakingPosition._toDouble(json['amount'] ?? json['value'] ?? 0),
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}
