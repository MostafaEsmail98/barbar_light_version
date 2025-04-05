import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/common_app_dialog.dart';
import 'package:frezka/components/dotted_line.dart';
import 'package:frezka/screens/branch/view/select_service_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/extensions/date_extensions.dart';
import 'package:frezka/utils/extensions/int_extension.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../components/slot_widget.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../branch_repository.dart';
import '../model/branch_configuration_response.dart';

class BranchTimesScreen extends StatefulWidget {
  final int BranchId;
  final int employeeId;
  final employeeName;

  const BranchTimesScreen(
      {super.key,
      required this.BranchId,
      required this.employeeId,
      this.employeeName});

  @override
  State<BranchTimesScreen> createState() => _BranchTimesScreenState();
}

class _BranchTimesScreenState extends State<BranchTimesScreen> {
  Future<BranchConfigurationResponse>? futureTimeSlotList;

  Future<BranchConfigurationResponse>? fetchBranchConfigurationApi() {
    futureTimeSlotList = getBranchConfiguration(widget.BranchId);
    return futureTimeSlotList;
  }

  DateTime selectedHorizontalDate = DateTime.now();
  int selectedIndex = -1;

  List<String> monthList = List.generate(12, (index) {
    if (DateTime.now().month <= index + 1) {
      return (index + 1).toMonthName();
    } else {
      return '0';
    }
  });
  int currentMonthNumber = DateTime.now().month;

  int selectedMonthIndex = DateTime.now().month - 1; // Current month
  int selectedDayIndex = DateTime.now().day - 1; // Current day
  int currentYear = DateTime.now().year;

  List<Map<String, String>> days = [];

  String startTime = DEFAULT_SLOT_INTERVAL_DURATION;
  String endTime = DEFAULT_SLOT_INTERVAL_DURATION;
  void init() async {
    fetchBranchConfigurationApi();
  }

  @override
  void initState() {
    super.initState();
    generateDaysForMonth(selectedMonthIndex);
    init();
    bookingRequestStore.setDateInRequest(selectedHorizontalDate
        .setFormattedDate(DateFormatConst.DATE_FORMAT_5)
        .toString());
    bookingRequestStore.setEmployeeIdInRequest(widget.employeeId);

    bookingRequestStore.setCouponApplied(false);
  }

  // Generate days for the selected month
  void generateDaysForMonth(int monthIndex) {
    setState(() {
      days.clear();
      int daysInMonth = DateUtils.getDaysInMonth(currentYear, monthIndex + 1);

      for (int i = 1; i <= daysInMonth; i++) {
        DateTime date = DateTime(currentYear, monthIndex + 1, i);
        if (date.isToday || date.isAfter(DateTime.now())) {
          days.add({
            'day': DateFormat.E('ar').format(date), // Arabic day name
            'date': i.toString(),
          });
        }
      }
    });
  }

  void changeMonth(int direction) {
    setState(() {
      selectedMonthIndex = (selectedMonthIndex + direction) % monthList.length;
      if (selectedMonthIndex < 0) selectedMonthIndex += monthList.length;
      generateDaysForMonth(selectedMonthIndex);
    });
  }

  void changeBySelectMonth(int selected) {
    setState(() {
      selectedMonthIndex = selected;
      generateDaysForMonth(selected);
    });
  }

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
    selectedHorizontalDate = DateTime(selectedHorizontalDate.year,
        selectedMonthIndex + 1, selectedDayIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              locale.reserveNearestTime,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.selectDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: false,
                          child: Row(
                            children: monthList.asMap().entries.map((entry) {
                              int index = entry.key;
                              String month = entry.value;
                              bool isSelected = selectedMonthIndex == index;
                              // return (selectedDayIndex + 1) >
                              print(entry);
                              return 0 == entry.key
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () {
                                        changeBySelectMonth(index);
                                        isSelected == true;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          month,
                                          style: TextStyle(
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () => changeMonth(-1),
                        child: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => changeMonth(1),
                        child:
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: false,
                    child: Row(
                      children: days.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> day = entry.value;
                        bool isSelected = selectedDayIndex == index;
                        print('entry');
                        print(entry);

// (selectedDayIndex + 1) >
//                                 int.parse(day['date'].toString())
//                             ? Container()
//                             :
                        return GestureDetector(
                          onTap: () => selectDay(index),
                          child: Container(
                            width: 60,
                            height: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day['date']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  day['day']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Text(
                  locale.selectTime,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SnapHelperWidget(
                    future: fetchBranchConfigurationApi(),
                    loadingWidget: LoaderWidget(),
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        retryText: locale.reload,
                        imageWidget: ErrorStateWidget(),
                        onRetry: () {
                          appStore.setLoading(true);
                          fetchBranchConfigurationApi();
                          setState(() {});
                        },
                      );
                    },
                    onSuccess: (snap) {
                      if (snap.data == null) {
                        return NoDataWidget(
                          title: locale.noTimeSlots,
                          retryText: locale.reload,
                          onRetry: () {
                            appStore.setLoading(true);

                            fetchBranchConfigurationApi();
                            setState(() {});
                          },
                        );
                      }

                      if (snap.data!.slot.validate().any((element) =>
                          element.day ==
                          selectedHorizontalDate.weekday.getWeekDayName)) {
                        startTime = snap.data!.slot
                            .validate()
                            .firstWhere((element) =>
                                element.day ==
                                selectedHorizontalDate.weekday.getWeekDayName)
                            .startTime
                            .validate();
                        endTime = snap.data!.slot
                            .validate()
                            .firstWhere((element) =>
                                element.day ==
                                selectedHorizontalDate.weekday.getWeekDayName)
                            .endTime
                            .validate();
                      }

                      return ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          itemBuilder: (context, index) {
                            bool isSelected = selectedIndex == index;
                            print(dayToNumber(
                                snap.data?.slot?[index].day.toString()));
                            //  snap.data?.slot?[index].day!=
                            // return dayToNumber(snap.data?.slot?[index].id
                            //             .toString()) ==
                            var dayindexedbook = dayToNumber(
                                snap.data?.slot?[index].day.toString());
                            var intevalsList = splitIntoHourlyMaps(
                                snap.data?.slot?[dayindexedbook].startTime
                                    .toString(),
                                snap.data?.slot?[dayindexedbook].startTime);
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter setStates) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${snap.data?.slot?[dayindexedbook].startTime} - ${snap.data?.slot?[dayindexedbook].endTime}"),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 37,
                                            child: DottedLine(
                                              direction: Axis.vertical,
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // showDialog(
                                                //   context: context,
                                                //   useSafeArea: false,
                                                //   builder:
                                                //       (BuildContext context) =>
                                                //           CommonAppDialog(
                                                //     title: locale
                                                //             .bookingSuccessful +
                                                //         isSelected.toString(),
                                                //     // subTitle: locale
                                                //     //     .yourBookingForHairBookingMessage,
                                                //     subTitle: locale
                                                //             .yourBookingForHairBookingMessage +
                                                //         ' ' +
                                                //         snap.data!.slot![index]
                                                //             .startTime
                                                //             .toString() +
                                                //         ' - ' +
                                                //         snap.data!.slot![index]
                                                //             .endTime
                                                //             .toString(),

                                                //     buttonText:
                                                //         locale.goToBookings,
                                                //     onTap: () {
                                                //       // finish(context);
                                                //     },
                                                //   ),
                                                // );

                                                if (snap.data
                                                        ?.slot?[dayindexedbook]
                                                        .slotAvailability(
                                                            selectedHorizontalDate) ??
                                                    false) {
                                                  if (isSelected) {
                                                    selectedIndex = -1;
                                                    bookingRequestStore
                                                        .setTimeInRequest('');
                                                  } else {
                                                    selectedIndex = index;

                                                    bookingRequestStore
                                                        .setTimeInRequest(snap
                                                            .data!
                                                            .slot![
                                                                dayindexedbook]
                                                            .startTime
                                                            .validate());
                                                  }
                                                  setStates(() =>
                                                      isSelected = !isSelected);
                                                } else {
                                                  toast(locale
                                                      .youCannotBookPrevious);
                                                }
                                                print("selectedHorizontalDate"
                                                    .toString());
                                                print(selectedHorizontalDate
                                                    .toString());
                                                print("selectedHorizontalDate"
                                                    .toString());
                                                print(selectedHorizontalDate
                                                    .toString());
                                                print("startTime" +
                                                    snap
                                                        .data!
                                                        .slot![dayindexedbook]
                                                        .startTime
                                                        .validate()
                                                        .toString());
                                                print(selectedHorizontalDate
                                                    .toString());
                                                setState(() {});
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(16),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: !isSelected
                                                            ? Colors.white
                                                            : Colors.green),
                                                    color: snap
                                                                .data
                                                                ?.slot?[
                                                                    dayindexedbook]
                                                                .slotAvailability(
                                                                    selectedHorizontalDate) ??
                                                            false
                                                        ? isSelected
                                                            ? Colors.white
                                                            : primaryColor
                                                        : redColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Center(
                                                    child: Text(
                                                  !(snap
                                                              .data
                                                              ?.slot?[
                                                                  dayindexedbook]
                                                              .slotAvailability(
                                                                  selectedHorizontalDate) ??
                                                          false)
                                                      ? locale.reserved
                                                      : locale
                                                          .availableReserveNow,
                                                  style: TextStyle(
                                                      color: !isSelected
                                                          ? Colors.white
                                                          : Colors.green,
                                                      fontSize: 16),
                                                )),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ]);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: 5,
                            );
                          },
                          itemCount: 1);
                      // itemCount: snap.data?.slot?.length ?? 0);
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    SelectServiceScreen(
                      employeeId: widget.employeeId,
                      BranchId: widget.BranchId,
                      employeeName: widget.employeeName,
                    ).launch(context);
                  },
                  child: Container(
                    height: context.height() / 15,
                    margin: EdgeInsets.only(top: 5),
                    // padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                        child: Text(
                      locale.next,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    )),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

int dayToNumber(String? day) {
  Map<String, int> days = {
    "monday": 1,
    "tuesday": 2,
    "wednesday": 3,
    "thursday": 4,
    "friday": 5,
    "saturday": 6,
    "sunday": 7,
  };
  return days[day] ?? -1; // Returns -1 if the day is invalid
}

// void main() {
//   // Example usage
//   String startTime = "09:30"; // 9:30 AM
//   String endTime = "14:15";   // 2:15 PM

//   List<Map<String, String>> hourlyIntervals = splitIntoHourlyMaps(startTime, endTime);

//   // Print results
//   for (var interval in hourlyIntervals) {
//     print("Start: ${interval['start']} - End: ${interval['end']}");
//   }
// }

List<Map<String, String>> splitIntoHourlyMaps(String? start, String? end) {
  List<Map<String, String>> intervals = [];

  // Parse hours and minutes
  List<String> startParts = start.toString().split(":");
  List<String> endParts = end.toString().split(":");

  int startHour = int.parse(startParts[0]);
  int startMinute = int.parse(startParts[1]);

  int endHour = int.parse(endParts[0]);
  int endMinute = int.parse(endParts[1]);

  // Set initial current start time
  int currentHour = startHour;

  while (currentHour < endHour) {
    String currentStart = "${currentHour.toString().padLeft(2, '0')}:"
        "${currentHour == startHour ? startMinute.toString().padLeft(2, '0') : '00'}";

    String currentEnd = "${(currentHour + 1).toString().padLeft(2, '0')}:00";

    intervals.add({'start': currentStart, 'end': currentEnd});

    currentHour++;
  }

  // Handle the last interval
  String lastStart = "${endHour.toString().padLeft(2, '0')}:00";
  String lastEnd =
      "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";
  intervals.add({'start': lastStart, 'end': lastEnd});

  return intervals;
}
