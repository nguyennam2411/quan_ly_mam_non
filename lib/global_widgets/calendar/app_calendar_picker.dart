import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class AppCalendarPicker extends StatefulWidget {
  final DateRangePickerController controller;
  final DateTime initialDate;
  final Function(DateTime) onSelectionChanged;
  final Function(DateTime)? onMonthChanged;
  final Color? Function(DateTime)? getEventColor;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String title;

  const AppCalendarPicker({
    super.key,
    required this.controller,
    required this.initialDate,
    required this.onSelectionChanged,
    this.onMonthChanged,
    this.getEventColor,
    this.minDate,
    this.maxDate,
    this.title = 'Chọn ngày',
  });

  @override
  State<AppCalendarPicker> createState() => _AppCalendarPickerState();
}

class _AppCalendarPickerState extends State<AppCalendarPicker> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate;
  }

  void _onViewChanged(DateRangePickerViewChangedArgs args) {
    final visibleDates = args.visibleDateRange;
    if (visibleDates.startDate != null && visibleDates.endDate != null) {
      final middleDate = visibleDates.startDate!.add(
        visibleDates.endDate!.difference(visibleDates.startDate!) ~/ 2,
      );
      
      // Use microtask to avoid setState() during build error
      Future.delayed(Duration.zero, () {
        if (mounted && (_currentMonth.year != middleDate.year || _currentMonth.month != middleDate.month)) {
          setState(() {
            _currentMonth = middleDate;
          });
          widget.onMonthChanged?.call(middleDate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.outline),
              ),
            ],
          ),
          AppConstants.spacingM,

          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () => widget.controller.backward?.call(),
              ),
              Text(
                DateFormat('MMMM yyyy', 'vi').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () => widget.controller.forward?.call(),
              ),
            ],
          ),

          Expanded(
            child: SfDateRangePicker(
              controller: widget.controller,
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: widget.initialDate,
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              headerHeight: 0,
              selectionShape: DateRangePickerSelectionShape.circle,
              selectionColor: Colors.transparent,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  widget.onSelectionChanged(args.value);
                }
              },
              onViewChanged: _onViewChanged,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                firstDayOfWeek: 1,
                showTrailingAndLeadingDates: true,
              ),
              cellBuilder: (BuildContext context, DateRangePickerCellDetails details) {
                final date = details.date;
                final bool isToday = DateUtils.isSameDay(date, DateTime.now());
                final bool isSelected = DateUtils.isSameDay(date, widget.controller.selectedDate);
                
                final Color? eventColor = widget.getEventColor?.call(date);

                return Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected 
                                ? AppColors.onPrimary 
                                : (date.month != _currentMonth.month) 
                                  ? AppColors.outline.withOpacity(0.5)
                                  : AppColors.onSurface,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (eventColor != null && eventColor != Colors.transparent)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white70 : eventColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
