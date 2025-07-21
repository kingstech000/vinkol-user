import 'package:flutter/material.dart';
import 'package:starter_codes/features/booking/view/widget/maps_display.dart';
import 'package:starter_codes/features/booking/view/widget/ride_detail_input_field.dart';
import 'package:starter_codes/widgets/app_bar/nav_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(
            //   padding:
            //       EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //   child: LocationTags(),
            // ),
            Gap.h16,
            const MapDisplay(),
            Gap.h16,
            const RideDetailsInput(),
            Gap.h16,
          ],
        ),
      ),
    );
  }
}
