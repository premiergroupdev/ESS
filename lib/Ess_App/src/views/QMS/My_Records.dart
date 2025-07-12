import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../base/utils/constants.dart';
import '../../models/api_response_models/warehouse_list_model.dart';
import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import 'package:intl/intl.dart';
import '../../styles/text_theme.dart';
import 'My_Records_view_model.dart';


class My_Records extends StatefulWidget {
  Warehouselist? data;
  My_Records({ this.data});
  @override
  State<My_Records> createState() => _Create_new_sheetState();
}



class _Create_new_sheetState extends State<My_Records> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RecordViewModel>.reactive(
      builder: (viewModelContext, model, child) =>
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GeneralAppBar(
                          title: "My Records",
                          onMenuTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          onNotificationTap: () {}),



                      (model.isBusy == true)
                          ? Center( child: CircularProgressIndicator (
                        color: AppColors.primary,) )
                          :
                      SizedBox(
                        height: context.screenSize().height - 145,
                        child: Padding(
                          padding:  EdgeInsets.all(1.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DateContainer(
                                      title: "Start Date",
                                      selectedDate: model.startDates,

                                      range: model.formattedStartDate,
                                      onDateSelected: (range) {
                                        setState(() {
                                          model.startDates = range;
                                          model.formattedStartDate = model.dateFormat.format(
                                              model.startDates ?? range);});
                                        setState(() {
                                          if (model.formattedStartDate != null &&
                                              model.formattedEndDate != null &&
                                              model.formattedStartDate.compareTo(model.formattedEndDate) <= 0) {
                                            model.temp_list(context)  ;                                        } else {
                                            // Handle the case where formattedStartDate is greater than formattedEndDate
                                            Constants.customErrorSnack(context, "Start date should be less than or equal to End date");
                                          }

                                          print("Start date");
                                          print(model.formattedStartDate);
                                          print(model.formattedEndDate);
                                          // show = true;
                                        });
                                      }

                                  ),




                                  DateContainer(
                                      title: "End Date",
                                      selectedDate: model.endDates,
                                      range: model.formattedEndDate,
                                      onDateSelected: (range) {
                                        setState(() {
                                          model.endDates = range;
                                          model.formattedEndDate = model.dateFormat.format(
                                              model.endDates ?? range);
                                        });
                                        //getSalesReportData();
                                        setState(() {
                                          if (model.formattedStartDate != null &&
                                              model.formattedEndDate != null &&
                                              model.formattedStartDate.compareTo(model.formattedEndDate) <= 0) {
                                            model.temp_list(context)  ;                                              } else {

                                            Constants.customErrorSnack(context, "Start date should be less than or equal to End date");
                                          }

                                          print("End date");
                                          // print(formattedStartDate);
                                          // print(formattedEndDate);

                                        });
                                      }

                                  ),


                                ],
                              ),
                              ((model.datalist?.length ?? 0) > 0) ?
                              Expanded(
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true, // To allow the list to take up available space
                                  itemCount: model.datalist.length,
                                  itemBuilder: (BuildContext context, index) {
                                    var data = model.datalist[index];

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        color: Colors.blue.shade50,
                                        elevation: 5,
                                        // margin: EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(16),

                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Align(
                                                alignment: Alignment.topCenter,  // You can also use Alignment.topLeft or Alignment.topRight
                                                child:
                                                Container(
                                                  width: 300,
                                                  padding:EdgeInsets.all(12),
                                                  decoration:BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.2), // Shadow color with some transparency
                                                          spreadRadius: 2, // How much the shadow will spread
                                                          blurRadius: 4,  // How blurred the shadow will be
                                                          offset: Offset(0, 4), // Shadow position (x, y)
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: AppColors.primary

                                                  ),
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Thermometer Number: ",
                                                                style: TextStyle(color: Colors.white, fontSize: 15),
                                                              ),
                                                              TextSpan(
                                                                text: "${data.thermometerNo}",
                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold , fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 2,),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Warehouse: ",

                                                                style: TextStyle(color: Colors.white , fontSize: 15),
                                                              ),
                                                              TextSpan(
                                                                text: "${data.warehouse}",
                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold , fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 2,),
                                                        Text.rich(
                                                          TextSpan(
                                                            children:
                                                            [
                                                              TextSpan(
                                                                text: "Month Year: ",
                                                                style: TextStyle(color: Colors.white , fontSize: 15),),
                                                              TextSpan(
                                                                text: "${data.monthYear}",
                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold , fontSize: 15),),
                                                            ],
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 30,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [

                                                      // Add some space between the icon and text
                                                      Text(
                                                        "Temperature Reading",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.black,
                                                        ),
                                                      ),
                                                      SizedBox(width: 2),
                                                      Icon(
                                                        Icons.thermostat,  // Thermometer icon
                                                        size: 20,           // Size of the icon
                                                        color: Colors.red, // Icon color
                                                      ),
                                                    ],
                                                  ),

                                                  InkWell(
                                                    onTap: ()
                                                    {
                                                      model.showimage(context, data.attach1);
                                                    },child:
                                                  Container(

                                                    padding:EdgeInsets.all(6),
                                                    decoration:BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2), // Shadow color with some transparency
                                                            spreadRadius: 2, // How much the shadow will spread
                                                            blurRadius: 4,  // How blurred the shadow will be
                                                            offset: Offset(0, 4), // Shadow position (x, y)
                                                          ),
                                                        ],
                                                        borderRadius: BorderRadius.circular(8),
                                                        color: AppColors.primary
                                                    ),

                                                    child: Text("View image", style: TextStyle(color: Colors.white, fontSize: 13),),
                                                  ),)
                                                ],
                                              ),
                                              Text("Current Temperature: ${data.curTemp}", style: TextStyle(color: Colors.black)),
                                              Text("Maximum Temperature: ${data.maxTemp}", style: TextStyle(color: Colors.black)),
                                              Text("Minimum Temperature: ${data.minTemp}", style: TextStyle(color: Colors.black)),

                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [

                                                      // Space between icon and text
                                                      Text(
                                                        "Humidity Reading",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.black,
                                                        ),

                                                      ),
                                                      SizedBox(width: 2),
                                                      Icon(
                                                        Icons.water_drop,  // Water drop icon for humidity
                                                        size: 20,           // Size of the icon
                                                        color: Colors.blue,  // Icon color
                                                      ),
                                                    ],
                                                  )
                                                  ,
                                                  InkWell(
                                                    onTap: ()
                                                    {
                                                      model.showimage(context, data.attach2);
                                                    },
                                                    child: Container(

                                                      padding:EdgeInsets.all(6),
                                                      decoration:BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.2), // Shadow color with some transparency
                                                              spreadRadius: 2, // How much the shadow will spread
                                                              blurRadius: 4,  // How blurred the shadow will be
                                                              offset: Offset(0, 4), // Shadow position (x, y)
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: AppColors.primary

                                                      ),

                                                      child: Text("View image", style: TextStyle(color: Colors.white, fontSize: 13),),
                                                    ),
                                                  ),


                                                ],
                                              ),
                                              Text("Current Humidity: ${data.currHumidity}", style: TextStyle(color: Colors.black)),
                                              Text("Maximum Humidity: ${data.maxHumidity}", style: TextStyle(color: Colors.black)),
                                              Text("Minimum Humidity: ${data.minHumidity}", style: TextStyle(color: Colors.black)),
                                              SizedBox(height: 10,),
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [

                                                    InkWell(
                                                      onTap: ()
                                                      {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              backgroundColor: AppColors.primary, // Custom primary background color
                                                              title: Text(
                                                                "Confirm Your Decision",
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white, // White text color
                                                                ),
                                                              ),
                                                              content: Text(
                                                                "Are you sure you want to delete?",
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Colors.white, // White content text
                                                                ),
                                                              ),
                                                              actions: <Widget>[
                                                                // Cancel Button
                                                                TextButton(
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      color: Colors.white, // White color for cancel button text
                                                                    ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                    // Optionally reset the selection if the user cancels
                                                                                                                                     },
                                                                ),
                                                                // Confirm Button
                                                                TextButton(
                                                                  child: Text(
                                                                    "Confirm",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.white, // White color for confirm button text
                                                                    ),
                                                                  ),
                                                                  onPressed: () async {


                                                                    await model.Delete_record(context,data.id.toString(), index);
                                                                    Navigator.pop(context);










                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.2), // Shadow color with some transparency
                                                                spreadRadius: 2, // How much the shadow will spread
                                                                blurRadius: 4,  // How blurred the shadow will be
                                                                offset: Offset(0, 4), // Shadow position (x, y)
                                                              ),
                                                            ],
                                                            color: Colors.red,
                                                            borderRadius: BorderRadius.circular(8)),

                                                        child: Icon(Icons.delete,color: Colors.red,),
                                                      ),
                                                    )


                                                  ]
                                              ),

                                            ],
                                          ),

                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ) :

                                Center(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20,),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Data Not Available",
                                          style: TextStyling.bold18.copyWith(color: AppColors.darkGrey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      viewModelBuilder: () => RecordViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}



class DateContainer extends StatefulWidget {
  final String title;
  final String range;
  final Function(DateTime) onDateSelected;
  DateTime? selectedDate;


  DateContainer({
    Key? key,
    required this.title,
    required this.range,
    required this.selectedDate,

    required this.onDateSelected,
  }) : super(key: key);

  @override
  _DateContainerState createState() => _DateContainerState();
}



class _DateContainerState extends State<DateContainer> {
  Future<void> showMonthYearPicker(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Month & Year"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedDate.month,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    selectedDate = DateTime(selectedDate.year, value);
                  }
                },
              ),
              DropdownButton<int>(
                value: selectedDate.year,
                items: List.generate(25, (index) {
                  int year = 2000 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text("$year"),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    selectedDate = DateTime(value, selectedDate.month);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                print("Selected: ${selectedDate.month}-${selectedDate.year}");
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: widget.selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: AppColors.primary, // Set your desired color here
               //   : AppColors.primary,
                  colorScheme: ColorScheme.light(primary: AppColors.primary),
                  buttonTheme: ButtonThemeData(
                      textTheme: ButtonTextTheme.primary),
                ),
                child: child!,
              );
            },
          );

          if (picked != null && picked != widget.selectedDate) {
            setState(() {
              widget.selectedDate = picked;
              widget.onDateSelected?.call(picked);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: 150,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(widget.selectedDate!)
                        : widget.range,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );

  }
}

