import 'dart:convert';
import 'dart:developer';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/model/wash_response.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:car_wash_employee/features/washes/exterior/exterior_before_wash_page.dart';
import 'package:car_wash_employee/features/washes/interior/interior_before_wash_page.dart';
import 'package:car_wash_employee/features/washes/pressure_wash/pressure_before_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:maps_launcher/maps_launcher.dart';

class TodayDetailCard extends ConsumerStatefulWidget {
  const TodayDetailCard({
    super.key,
    required this.assignedCar,
    required this.isActive,
  });
  final AssignedCar assignedCar;
  final bool isActive;
  

  @override
  ConsumerState<TodayDetailCard> createState() => _TodayDetailCardState();
}

class _TodayDetailCardState extends ConsumerState<TodayDetailCard> {
  WashResponse? washResponse;
  Future<void> openMap() async {
    final double latitude = double.parse(widget.assignedCar.latitude);
    final double longitude = double.parse(widget.assignedCar.longitude);
    MapsLauncher.launchCoordinates(latitude, longitude);
  }

  Future<void> carWash() async {
    const url = 'https://wash.sortbe.com/API/Employee/Dashboard/Car-Wash';

    final authState = ref.watch(authProvider);
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': authState.employee!.id,
          'car_id': widget.assignedCar.carId,
        },
      );

      final Map<String, dynamic> decodedJson = jsonDecode(response.body);

      if (decodedJson['status'] == 'Success') {
        setState(() {
          washResponse = WashResponse.fromJson(decodedJson);
        });
        print(washResponse);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(washResponse!.remarks),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      log('Error = $e');
    }
  }

  Future<void> handleCarWashNavigation() async {
    await carWash();
    if (washResponse != null) {
      if (widget.assignedCar.washName == interiorPremium ||
          widget.assignedCar.washName == interiorStandard ||
          widget.assignedCar.washName == pressureWashWithInterior) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InteriorBeforeWashPage(
              assignedCar: widget.assignedCar,
              washResponse: washResponse!,
            ),
          ),
        );
      } else if (widget.assignedCar.washName == exterior) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExteriorBeforeWashPage(
              assignedCar: widget.assignedCar,
              washResponse: washResponse!,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PressureBeforeWashPage(
              assignedCar: widget.assignedCar,
              washResponse: washResponse!,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get wash response'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.isActive) {
              handleCarWashNavigation();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.isActive
                  ? Colors.white
                  : const Color(0xFFD4D4D4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            height: 130,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 140.w,
                    child: Image.network(
                      widget.assignedCar.vehicleImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/car.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 10,
                      top: 15,
                      bottom: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assignedCar.vehicleNo,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          widget.assignedCar.modelName,
                          style: const TextStyle(
                            color: Color(0xFF001C63),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: openMap,
                              child: Container(
                                decoration: const BoxDecoration(
                                  // color: Colors.red,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'View Location',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      height: 350,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 10,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF9B9B9B),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          SizedBox(height: 20.h),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        ContinuousRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    backgroundColor:
                                                        const Color(
                                                            0xFF001C63)),
                                                child: Text(
                                                  widget.assignedCar.washName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 15.h),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 120,
                                                    child: Text(
                                                      'Customer Name',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF003EDC),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20.w),
                                                  Text(
                                                    widget
                                                        .assignedCar.clientName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15.h),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 120,
                                                    child: Text(
                                                      'Model Name',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF003EDC),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20.w),
                                                  Text(
                                                    widget
                                                        .assignedCar.modelName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15.h),
                                              const Text(
                                                'Remarks',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF003EDC),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Text(
                                                widget.assignedCar.washRemarks,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                softWrap: true,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.remove_red_eye_outlined),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
