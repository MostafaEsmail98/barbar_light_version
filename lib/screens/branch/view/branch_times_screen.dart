import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/common_app_dialog.dart';
import 'package:frezka/components/dotted_line.dart';
import 'package:frezka/screens/branch/view/select_service_screen.dart';
import 'package:frezka/screens/experts/employee_repository.dart';
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
  final employeePhone;

  const BranchTimesScreen(
      {super.key,
      required this.BranchId,
      required this.employeeId,
      this.employeeName, required this.employeePhone});

  @override
  State<BranchTimesScreen> createState() => _BranchTimesScreenState();
}

class _BranchTimesScreenState extends State<BranchTimesScreen> {
  Future<BranchConfigurationResponse>? futureTimeSlotList;

  String convertTo24HourFormat(String time12h) {
    try {
      // التأكد من أن AM / PM مكتوبة بشكل صحيح
      String formattedInput = time12h.trim().toUpperCase();

      // تحديد التنسيق المناسب بناءً على وجود دقائق
      DateFormat inputFormat;
      if (formattedInput.contains(":")) {
        inputFormat = DateFormat('h:mma'); // مثل 2:30 PM
      } else {
        inputFormat = DateFormat('ha'); // مثل 2 PM
      }

      // تحويل الوقت إلى كائن DateTime
      DateTime parsedTime = inputFormat.parse(formattedInput);

      // إخراج النتيجة بصيغة HH:mm:ss
      return DateFormat('HH:mm:ss').format(parsedTime);
    } catch (e) {
      // في حال حدوث خطأ في التحويل
      return 'Invalid time format';
    }
  }

  Future<BranchConfigurationResponse>? fetchBranchConfigurationApi() {
    futureTimeSlotList = getBranchConfiguration(widget.BranchId);
    print("--------------------");
    print(futureTimeSlotList);
    print("--------------------");
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
  int selectedDayIndex = DateTime.now().day; // Current day
  int currentYear = DateTime.now().year;

  List<Map<String, String>> days = [];

  String startTime = DEFAULT_SLOT_INTERVAL_DURATION;
  String endTime = DEFAULT_SLOT_INTERVAL_DURATION;

  List intevalsListBookings = [];
  List reserved_periods = [];

  int bookindextemp = 0;

  // Update initState initialization
  @override
  void initState() {
    super.initState();
    monthList = List.generate(12, (i) => (i + 1).toMonthName());
    generateDaysForMonth(selectedMonthIndex);

    // Initialize with correct slot for today
    final today = DateTime.now();
    fetchBranchConfigurationApi()!.then((config) {
      final slotIndex = today.weekday - 1;
      final slot = config.data!.slot![slotIndex];

      String? startTime = slot.startTime;
      if (today.hour >= int.parse(startTime!.split(':').first)) {
        startTime = '${today.hour + 1}:00';
      }

      setState(() {
        intevalsListBookings = splitIntoHourlyMaps(startTime!, slot.endTime!);
      });
    });

    // Load reservations
    getEmployeeDetail(
      employeeId: widget.employeeId,
      branchId: widget.BranchId,
      context: context,
    )!
        .then((res) {
      setState(() => reserved_periods = res.reserved_periods!.toList());
    });
    selectDay();
  }

  void generateDaysForMonth(int monthIndex) {
    setState(() {
      days.clear();
      final daysInMonth = DateUtils.getDaysInMonth(currentYear, monthIndex + 1);

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(currentYear, monthIndex + 1, day);
        if (date.isToday || date.isAfter(DateTime.now())) {
          days.add({
            'day': DateFormat.E('ar').format(date),
            'date': day.toString().padLeft(0, '0'),
          });
        }
      }
      selectedIndex = -1;
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

  void selectDay({int index = 0}) {
    final selectedDate = DateTime(
      currentYear,
      selectedMonthIndex + 1,
      int.parse(
          days[index]['date']!), // Use actual day from generated days list
    );

    setState(() {
      selectedHorizontalDate = selectedDate;
      selectedDayIndex = selectedDate.day;
    });

    bookingRequestStore.setDateInRequest(selectedDate
        .setFormattedDate(DateFormatConst.DATE_FORMAT_5)
        .toString());

    fetchBranchConfigurationApi()!.then((config) {
      final slotIndex = selectedDate.weekday - 1; // Correct 0-based index
      final slot = config.data!.slot![slotIndex];

      String startTime = slot.startTime!;
      if (selectedDate.isToday) {
        final currentHour = DateTime.now().hour;
        final slotStartHour = int.parse(startTime.split(':').first);
        if (currentHour >= slotStartHour) {
          startTime = '${(currentHour + 1).toString().padLeft(0, '0')}:00';
        }
      }

      setState(() {
        intevalsListBookings = splitIntoHourlyMaps(startTime, slot.endTime!);
      });
    });
  }

  // void selectDay(int index) {
  //   setState(() {
  //     selectedDayIndex = index + DateTime.now().day;
  //   });

  //   selectedHorizontalDate = DateTime(
  //       selectedHorizontalDate.year, selectedMonthIndex + 1, selectedDayIndex);

  //   bookingRequestStore.setDateInRequest(selectedHorizontalDate
  //       .setFormattedDate(DateFormatConst.DATE_FORMAT_5)
  //       .toString());
  //   print('selectedHorizontalDate');
  //   print(selectedHorizontalDate);
  //   var conf = fetchBranchConfigurationApi();
  //   conf!.then((onValue) {
  //     print("################################");
  //     print(onValue);
  //     print("################################");
  //     var start_time =
  //         onValue.data!.slot![selectedHorizontalDate.weekday].startTime;
  //     if (DateTime.now().day == selectedDayIndex) {
  //       start_time = DateTime.now().hour.toString() + ':00';
  //     }
  //     onValue.data!.slot![selectedHorizontalDate.weekday];
  //     var intevalsListBookingsnew = splitIntoHourlyMaps(start_time,
  //         onValue.data!.slot![selectedHorizontalDate.weekday].endTime);
  //     setState(() {
  //       intevalsListBookings = intevalsListBookingsnew;
  //       startTime = start_time.toString();
  //       endTime = onValue.data!.slot![selectedHorizontalDate.weekday].endTime
  //           .toString();
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SingleChildScrollView(
        child: Column(
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
                                // print(entry);
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
                          bool isSelected =
                              selectedDayIndex == index + DateTime.now().day;
                          return GestureDetector(
                            onTap: () {
                              selectDay(index: index);
                            },
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
                              fetchBranchConfigurationApi();
                              setState(() {});
                            },
                          );
                        }
        
                        // if (snap.data!.slot.validate().any((element) =>
                        //     element.day ==
                        //     selectedHorizontalDate.weekday.getWeekDayName)) {
                        //   startTime = snap.data!.slot
                        //       .validate()
                        //       .firstWhere((element) =>
                        //           element.day ==
                        //           selectedHorizontalDate.weekday.getWeekDayName)
                        //       .startTime
                        //       .validate();
                        //   endTime = snap.data!.slot
                        //       .validate()
                        //       .firstWhere((element) =>
                        //           element.day ==
                        //           selectedHorizontalDate.weekday.getWeekDayName)
                        //       .endTime
                        //       .validate();
                        //   appStore.setLoading(true);
                        // }
        
                        return ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            itemBuilder: (context, index) {
                              bool isSelected = selectedIndex == index;
                              // print(dayToNumber(
                              //     snap.data?.slot?[index].day.toString()));
                              //  snap.data?.slot?[index].day!=
                              // return dayToNumber(snap.data?.slot?[index].id
                              //             .toString()) ==
                              // var dayindexedbook = dayToNumber(
                              //     snap.data?.slot?[index].day.toString());
                              // var intevalsList = splitIntoHourlyMaps(
                              //     snap.data?.slot?[dayindexedbook].startTime
                              //         .toString(),
                              //     snap.data?.slot?[dayindexedbook].endTime);
                              // var element;
                              // print('intevalsList');
                              // print(intevalsList);
        
                              // element = intevalsList[0];
                              // print('element');
                              // print(element);
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setStates) {
                                  return GestureDetector(
                                    onTap: () {
                                      print(bookingRequestStore.date +
                                          ' ' +
                                          convertTo24HourFormat(
                                              intevalsListBookings[index]
                                                  ['start']));
                                      print(convertTo24HourFormat(
                                          intevalsListBookings[index]['start']));
                                      print(reserved_periods);
                                      print(bookingRequestStore.date);
                                      if (reserved_periods.contains(
                                          bookingRequestStore.date +
                                              ' ' +
                                              convertTo24HourFormat(
                                                  intevalsListBookings[index]
                                                      ['start']))) {
                                        toast(
                                            'الموعد محجوز بالفعل اختر موعد اخر !');
                                        return;
                                      }
                                      setStates(() => isSelected = !isSelected);
                                      if (isSelected) {
                                        setState(() => selectedIndex = index);
                                        bookingRequestStore.setTimeInRequest(
                                            intevalsListBookings[index]['start']
                                                .toString());
                                        print(intevalsListBookings[index]['start']
                                            .toString());
                                      } else {
                                        setState(() => selectedIndex = -1);
                                        bookingRequestStore.setTimeInRequest('');
                                      }
                                    },
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "${intevalsListBookings[index]['start']} - ${intevalsListBookings[index]['end']}",
                                              style:
                                                  TextStyle(color: Colors.black),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 37,
                                                child: DottedLine(
                                                  direction: Axis.vertical,
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.all(16),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: reserved_periods.contains(bookingRequestStore
                                                                      .date +
                                                                  ' ' +
                                                                  convertTo24HourFormat(intevalsListBookings[index]
                                                                      ['start']))
                                                              ? Colors.red
                                                              : (!isSelected &&
                                                                      selectedIndex !=
                                                                          index
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .green)),
                                                      color:
                                                          // snap
                                                          //             .data
                                                          //             ?.slot?[
                                                          //                 dayindexedbook]
                                                          //             .slotAvailability(
                                                          //                 selectedHorizontalDate) ??
                                                          !reserved_periods.contains(
                                                                  bookingRequestStore
                                                                          .date +
                                                                      ' ' +
                                                                      convertTo24HourFormat(
                                                                          intevalsListBookings[index]['start']))
                                                              ? isSelected && selectedIndex == index
                                                                  ? Colors.white
                                                                  : primaryColor
                                                              : redColor,
                                                      borderRadius: BorderRadius.circular(15)),
                                                  child: Center(
                                                      child: Text(
                                                    // !(snap
                                                    //             .data
                                                    //             ?.slot?[
                                                    //                 dayindexedbook]
                                                    //             .slotAvailability(
                                                    //                 selectedHorizontalDate) ??
                                                    //         false)
                                                    reserved_periods.contains(
                                                            bookingRequestStore
                                                                    .date +
                                                                ' ' +
                                                                convertTo24HourFormat(
                                                                    intevalsListBookings[
                                                                            index]
                                                                        [
                                                                        'start']))
                                                        ? locale.reserved
                                                        : locale
                                                            .availableReserveNow,
                                                    style: TextStyle(
                                                        color: reserved_periods.contains(
                                                                bookingRequestStore
                                                                        .date +
                                                                    ' ' +
                                                                    convertTo24HourFormat(
                                                                        intevalsListBookings[
                                                                                index]
                                                                            [
                                                                            'start']))
                                                            ? Colors.white
                                                            : !isSelected &&
                                                                    selectedIndex !=
                                                                        index
                                                                ? Colors.white
                                                                : Colors.green,
                                                        fontSize: 16),
                                                  )),
                                                ),
                                              )
                                            ],
                                          )
                                        ]),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 5,
                              );
                            },
                            // itemCount: 1);
                            itemCount: intevalsListBookings.length ?? 0);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (selectedIndex == -1) {
                        toast('الرجاء اختيار موعد');
                        return;
                      }
                      print(widget.employeeId);
                      SelectServiceScreen(
                        employeePhone: widget.employeePhone,
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
// void main() {
//   // Example usage
//   String startTime = "09:30:00"; // 9:30 AM
//   String endTime = "14:15:00"; // 2:15 PM

//   List<Map<String, String>> hourlyIntervals =
//       splitIntoHourlyMaps(startTime, endTime);

//   // Print results
//   for (var interval in hourlyIntervals) {
//     print("Start: ${interval['start']} - End: ${interval['end']}");
//   }
// }

// List<Map<String, String>> splitIntoHourlyMaps(String start, String end) {
//   final format = DateFormat('HH:mm');
//   DateTime startTime = format.parse(start);
//   DateTime endTime = format.parse(end);

//   // Handle overnight slots
//   if (endTime.isBefore(startTime)) {
//     endTime = endTime.add(Duration(days: 1));
//   }

//   List<Map<String, String>> intervals = [];
//   DateTime current = startTime;

//   while (current.isBefore(endTime)) {
//     DateTime next = current.add(Duration(hours: 1));
//     if (next.isAfter(endTime)) next = endTime;

//     intervals.add({
//       'start': format.format(current),
//       'end': format.format(next),
//     });

//     current = next;
//   }

//   return intervals;
// }

// List<Map<String, String>> splitIntoHourlyMaps(String start, String end) {
//   final inputFormat = DateFormat('HH:mm'); // input in 24-hour
//   final outputFormat = DateFormat('ha'); // output like 1AM, 2PM

//   DateTime startTime = inputFormat.parse(start);
//   DateTime endTime = inputFormat.parse(end);

//   if (endTime.isBefore(startTime)) {
//     endTime = endTime.add(Duration(days: 1));
//   }

//   List<Map<String, String>> intervals = [];
//   DateTime current = startTime;

//   while (current.isBefore(endTime)) {
//     DateTime next = current.add(Duration(hours: 1));
//     if (next.isAfter(endTime)) next = endTime;

//     intervals.add({
//       'start': outputFormat.format(current).toLowerCase(),
//       'end': outputFormat.format(next).toLowerCase(),
//     });

//     current = next;
//   }

//   return intervals;
// }

List<Map<String, String>> splitIntoHourlyMaps(String start, String end) {
  final inputFormat = DateFormat('HH:mm');
  final outputFormat = DateFormat('ha');

  DateTime startTime = inputFormat.parse(start);
  DateTime endTime = inputFormat.parse(end);

  if (endTime.isBefore(startTime)) {
    endTime = endTime.add(Duration(days: 1));
  }

  List<Map<String, String>> intervals = [];
  DateTime current = startTime;

  while (current.isBefore(endTime)) {
    DateTime next = current.add(Duration(hours: 1));
    if (next.isAfter(endTime)) next = endTime;

    String startFormatted = outputFormat.format(current).toLowerCase();
    String endFormatted = outputFormat.format(next).toLowerCase();

    intervals.add({
      'start': startFormatted,
      'end': endFormatted,
    });

    current = next;
  }

  // ✅ ترتيب الـ slots: am أولًا ثم pm
  intervals.sort((a, b) {
    bool aIsAm = a['start']!.contains('am');
    bool bIsAm = b['start']!.contains('am');
    if (aIsAm && !bIsAm) return -1;
    if (!aIsAm && bIsAm) return 1;
    return 0;
  });

  return intervals;
}
