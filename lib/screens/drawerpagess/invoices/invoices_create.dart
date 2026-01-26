// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/invoicecreatcontroller.dart';
import '../../drawercode.dart';

class InvoicesCreate extends StatefulWidget {
  const InvoicesCreate({super.key});

  @override
  State<InvoicesCreate> createState() => _InvoicesCreateState();
}

class _InvoicesCreateState extends State<InvoicesCreate> {
  InvoiceCreatController invoiceCreatController =
      Get.put(InvoiceCreatController());
  ColorNotifire notifire = ColorNotifire();
  TextEditingController dateinput = TextEditingController();
  TextEditingController dateinput1 = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
    dateinput.clear();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<InvoiceCreatController>(
        builder: (invoiceCreatController) {
      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: notifire.getBgColor,
                  drawer: const DrawerCode(),
                  appBar: AppBar(
                    backgroundColor: notifire.getBgColor,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    leading: constraints.maxWidth < 800
                        ? InkWell(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: Center(
                                    child: SvgPicture.asset(
                                  "assets/images/menu-left.svg",
                                  height: 20,
                                  width: 20,
                                  color: notifire.getTextColor,
                                ))))
                        : null,
                  ),
                  body: Padding(
                    padding: EdgeInsets.all(padding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildAppbar(width: constraints.maxWidth),
                          const SizedBox(
                            height: 60,
                          ),
                          _buildui(width: constraints.maxWidth),
                          const SizedBox(
                            width: 15,
                          ),
                          _buildui2(),
                        ],
                      ),
                    ),
                  ));
            } else if (constraints.maxWidth < 1000) {
              return Scaffold(
                backgroundColor: notifire.getBgColor,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: notifire.getBgColor,
                  child: Row(
                    children: [
                      const DrawerCode(),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 30, horizontal: padding),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildAppbar(width: constraints.maxWidth),
                                  const SizedBox(
                                    height: 64,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildui(width: constraints.maxWidth),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      _buildui2(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: notifire.getBgColor,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: notifire.getBgColor,
                  child: Row(
                    children: [
                      const DrawerCode(),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 30, horizontal: padding),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildAppbar(width: constraints.maxWidth),
                                  const SizedBox(
                                    height: 64,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: _buildui(
                                            width: constraints.maxWidth),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _buildui2(),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildui2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  // height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: notifire.getBgColor,
                      border: Border.all(color: notifire.getGry700_300Color)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Basic Info",
                          style: Typographyy.heading4
                              .copyWith(color: notifire.getTextColor),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoice number",
                              style: Typographyy.bodySmallSemiBold
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 56,
                              // width: 280,
                              child: TextField(
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: notifire.getTextColor),
                                decoration: InputDecoration(
                                  isDense: false,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  hintText: "hinttext",
                                  hintStyle: Typographyy.bodyMediumMedium
                                      .copyWith(
                                          color: notifire.getGry500_600Color),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoice date",
                              style: Typographyy.bodySmallSemiBold
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 56,
                              // width: 280,
                              child: TextField(
                                controller: dateinput,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101));
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    setState(() {
                                      dateinput.text = formattedDate;
                                    });
                                  } else {}
                                },
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: notifire.getTextColor),
                                decoration: InputDecoration(
                                  suffixIcon: Transform.translate(
                                    offset: const Offset(-7, 0),
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Center(
                                          child: SvgPicture.asset(
                                              "assets/images/calendar.svg",
                                              width: 22,
                                              height: 22,
                                              color: priMeryColor)),
                                    ),
                                  ),
                                  isDense: false,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  hintText: "Select Date",
                                  hintStyle: Typographyy.bodyMediumMedium
                                      .copyWith(
                                          color: notifire.getGry500_600Color),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Due date",
                              style: Typographyy.bodySmallSemiBold
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 56,
                              // width: 280,
                              child: TextField(
                                controller: dateinput1,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101));
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    setState(() {
                                      dateinput1.text = formattedDate;
                                    });
                                  } else {}
                                },
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: notifire.getTextColor),
                                decoration: InputDecoration(
                                  suffixIcon: Transform.translate(
                                    offset: const Offset(-7, 0),
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Center(
                                          child: SvgPicture.asset(
                                              "assets/images/calendar.svg",
                                              width: 22,
                                              height: 22,
                                              color: priMeryColor)),
                                    ),
                                  ),
                                  isDense: false,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  hintText: "Select Date",
                                  hintStyle: Typographyy.bodyMediumMedium
                                      .copyWith(
                                          color: notifire.getGry500_600Color),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color)),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Currency",
                              style: Typographyy.bodySmallSemiBold
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              offset: const Offset(0, 50),
                              color: notifire.getDrawerColor,
                              onOpened: () {
                                invoiceCreatController.setmenu(true);
                              },
                              onCanceled: () {
                                invoiceCreatController.setmenu(false);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: notifire.getGry700_300Color),
                                    color: Colors.transparent),
                                // width: 280,
                                child: Center(
                                  child: ListTile(
                                    dense: true,
                                    leading: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Center(
                                          child: SvgPicture.asset(
                                        invoiceCreatController.currencyLogo[
                                            invoiceCreatController
                                                .currencySelect],
                                        height: 22,
                                        width: 22,
                                      )),
                                    ),
                                    title: Text(
                                      invoiceCreatController.currencyName[
                                          invoiceCreatController
                                              .currencySelect],
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(
                                              color: notifire.getTextColor),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    trailing: SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: SvgPicture.asset(
                                          invoiceCreatController.menuopen
                                              ? "assets/images/chevron-up.svg"
                                              : "assets/images/chevron-down.svg",
                                          width: 25,
                                          height: 25,
                                        )),
                                  ),
                                ),
                              ),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                      padding: const EdgeInsets.all(0),
                                      enabled: false,
                                      child: SizedBox(
                                        height: 150,
                                        width: 250,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: invoiceCreatController
                                              .currencyLogo.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                invoiceCreatController
                                                    .setCurrency(index);
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 100,
                                                  ),
                                                  () {
                                                    Get.back();
                                                  },
                                                );
                                              },
                                              title: Text(
                                                invoiceCreatController
                                                    .currencyName[index],
                                                style: Typographyy
                                                    .bodyMediumMedium
                                                    .copyWith(
                                                        color: notifire
                                                            .getTextColor),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              leading: SvgPicture.asset(
                                                invoiceCreatController
                                                    .currencyLogo[index],
                                                height: 25,
                                                width: 25,
                                              ),
                                            );
                                          },
                                        ),
                                      )),
                                ];
                              },
                            ),
                          ],
                        ),
                        Divider(
                          height: 48,
                          color: notifire.getGry700_300Color,
                        ),
                        ListTile(
                          trailing: Switch(
                            inactiveTrackColor: notifire.getGry700_300Color,
                            value: invoiceCreatController.payment,
                            onChanged: (value) {
                              invoiceCreatController.setpayment(value);
                            },
                          ),
                          title: Text(
                            "Payment method",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                        ListTile(
                          trailing: Switch(
                            inactiveTrackColor: notifire.getGry700_300Color,
                            value: invoiceCreatController.fees,
                            onChanged: (value) {
                              invoiceCreatController.setfees(value);
                            },
                          ),
                          title: Text(
                            "Late fees",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                        ListTile(
                          trailing: Switch(
                            inactiveTrackColor: notifire.getGry700_300Color,
                            value: invoiceCreatController.notice,
                            onChanged: (value) {
                              invoiceCreatController.setnotice(value);
                            },
                          ),
                          title: Text(
                            "Notes",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: const Size.fromHeight(48),
                      backgroundColor: priMeryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Send Invoice",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: whiteColor),
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: const Size.fromHeight(48),
                      backgroundColor: notifire.getGry50_800Color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Preview",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: priMeryColor),
                    )),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: const Size.fromHeight(48),
                      backgroundColor: notifire.getGry50_800Color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Download",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: priMeryColor),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildui({required double width}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            width < 800
                ? Column(
                    children: [
                      _buildUiCompo1(),
                      const SizedBox(
                        height: 35,
                      ),
                      _buildUiCompo2(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildUiCompo1(),
                      ),
                      const SizedBox(
                        width: 35,
                      ),
                      Expanded(
                        child: _buildUiCompo2(),
                      ),
                    ],
                  ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(365),
                  1: FixedColumnWidth(158),
                  2: FixedColumnWidth(184),
                  3: FixedColumnWidth(164),
                  4: FixedColumnWidth(180),
                },
                children: [
                  TableRow(children: [
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                  ]),
                  TableRow(children: [
                    Row(
                      children: [
                        SizedBox(
                            height: 22,
                            width: 22,
                            child: Center(
                                child: SvgPicture.asset(
                                    "assets/images/menu-left.svg",
                                    height: 22,
                                    width: 22,
                                    color: notifire.getGry500_600Color))),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'ITEM',
                          style: Typographyy.bodyLargeExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text(
                        "QTY",
                        style: Typographyy.bodyLargeExtraBold
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text(
                        "HOURS",
                        style: Typographyy.bodyLargeExtraBold
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text(
                        "RATE",
                        style: Typographyy.bodyLargeExtraBold
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Text(
                            "TOTAL",
                            style: Typographyy.bodyLargeExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  TableRow(children: [
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                    Divider(height: 30, color: notifire.getGry700_300Color),
                  ]),
                  for (int a = 0; a < invoiceCreatController.items.length; a++)
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Text(
                          invoiceCreatController.items[a],
                          style: Typographyy.bodyMediumExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Text(
                          invoiceCreatController.qty[a],
                          style: Typographyy.bodyMediumExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Text(
                          invoiceCreatController.hours[a],
                          style: Typographyy.bodyMediumExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Text(
                          invoiceCreatController.rate[a],
                          style: Typographyy.bodyMediumExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: Text(
                              invoiceCreatController.total[a],
                              style: Typographyy.bodyMediumExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  invoiceCreatController.isAddItem
                      ? TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      invoiceCreatController.setIteamAdd();
                                    },
                                    controller:
                                        invoiceCreatController.itemController,
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                    keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      invoiceCreatController.setIteamAdd();
                                    },
                                    keyboardType: TextInputType.number,
                                    controller:
                                        invoiceCreatController.qtyController,
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      invoiceCreatController.setIteamAdd();
                                    },
                                    keyboardType: TextInputType.number,
                                    controller:
                                        invoiceCreatController.hoursController,
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      invoiceCreatController.setIteamAdd();
                                    },
                                    keyboardType: TextInputType.number,
                                    controller:
                                        invoiceCreatController.rateController,
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) {
                                      invoiceCreatController.setIteamAdd();
                                    },
                                    controller:
                                        invoiceCreatController.totalController,
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                )),
                          ),
                        ])
                      : const TableRow(children: [
                          SizedBox(),
                          SizedBox(),
                          SizedBox(),
                          SizedBox(),
                          SizedBox(),
                        ]),
                  TableRow(children: [
                    Divider(height: 40, color: notifire.getGry700_300Color),
                    Divider(height: 40, color: notifire.getGry700_300Color),
                    Divider(height: 40, color: notifire.getGry700_300Color),
                    Divider(height: 40, color: notifire.getGry700_300Color),
                    Divider(height: 40, color: notifire.getGry700_300Color),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: InkWell(
                          onTap: () {
                            invoiceCreatController.setIsAddItem(true);
                          },
                          child: Text("Add Item",
                              style: Typographyy.bodyMediumExtraBold
                                  .copyWith(color: priMeryColor))),
                    ),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Subtotal",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "\$1500",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  TableRow(children: [
                    const SizedBox(),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        "Discount",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            "Add",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: priMeryColor),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  TableRow(children: [
                    const SizedBox(),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        "Tax",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            "Add",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: priMeryColor),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  TableRow(children: [
                    const SizedBox(),
                    const SizedBox(),
                    Divider(color: notifire.getGry700_300Color, height: 40),
                    Divider(color: notifire.getGry700_300Color, height: 40),
                    Divider(color: notifire.getGry700_300Color, height: 40),
                  ]),
                  TableRow(children: [
                    const SizedBox(),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Total",
                        style: Typographyy.bodyLargeMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "\$1500",
                        style: Typographyy.bodyLargeMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUiCompo1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From:",
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          height: 88,
          // width: 338,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: notifire.getGry50_800Color,
          ),
          child: Center(
            child: ListTile(
              title: Text("M.s Design",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor)),
              leading: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage("assets/images/01.png")),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("OVN1290785",
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: notifire.getGry500_600Color)),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email",
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: notifire.getGry500_600Color)),
            const SizedBox(
              height: 8,
            ),
            _buildTextfilde(
                hinttext: "Enter Email", iconpath: "assets/images/mail.svg"),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address",
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: notifire.getGry500_600Color)),
            const SizedBox(
              height: 8,
            ),
            _buildTextfilde(
                hinttext: "Enter Address",
                iconpath: "assets/images/map-pin.svg"),
          ],
        ),
      ],
    );
  }

  Widget _buildUiCompo2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bill to:",
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(
          height: 24,
        ),
        PopupMenuButton(
          shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: notifire.getContainerColor,
          offset: const Offset(0, 90),
          onOpened: () {
            invoiceCreatController.setIsDropDown(true);
          },
          onCanceled: () {
            invoiceCreatController.setIsDropDown(false);

          },
          child: Container(
            height: 88,
            // width: 338,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: notifire.getGry50_800Color,
            ),
            child: Center(
              child: ListTile(
                title: Text(invoiceCreatController.dropdown1[invoiceCreatController.selectDrop],
                    style: Typographyy.bodyLargeExtraBold
                        .copyWith(color: notifire.getTextColor)),
                leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("assets/images/india.png")),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(invoiceCreatController.dropdown1value[invoiceCreatController.selectDrop],
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: notifire.getGry500_600Color)),
                ),
                trailing: Transform.translate(
                  offset: const Offset(-20, 0),
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                          child: SvgPicture.asset( invoiceCreatController.isDropDown ? "assets/images/chevron-up.svg" :"assets/images/chevron-down.svg",
                        height: 20,
                        width: 20,
                      ))),
                ),
              ),
            ),
          ),
          itemBuilder: (context) {
            return [PopupMenuItem(child: SizedBox(
              height: 250,
              width: 150,
              child: ListView.builder(
                itemCount: invoiceCreatController.dropdown1.length,
                itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    invoiceCreatController.setSelectDrop(index);
                    Get.back();
                  },
                  title: Text(invoiceCreatController.dropdown1[index],style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor)),
                  subtitle: Text(invoiceCreatController.dropdown1value[index],style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color)),);
              },),
            ))];
          },
        ),
        const SizedBox(
          height: 24,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email",
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: notifire.getGry500_600Color)),
            const SizedBox(
              height: 8,
            ),
            _buildTextfilde(
                hinttext: "Enter Email", iconpath: "assets/images/mail.svg"),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address",
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: notifire.getGry500_600Color)),
            const SizedBox(
              height: 8,
            ),
            _buildTextfilde(
                hinttext: "Enter Address",
                iconpath: "assets/images/map-pin.svg"),
          ],
        ),
      ],
    );
  }

  Widget _buildTextfilde({required String hinttext, required String iconpath}) {
    return SizedBox(
      height: 58,
      // width: 280,
      child: TextField(
        style:
            Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),
        decoration: InputDecoration(
          isDense: false,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifire.getGry700_300Color)),
          hintText: hinttext,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: SizedBox(
                height: 22,
                width: 22,
                child: Center(
                    child: SvgPicture.asset(iconpath,
                        height: 22,
                        width: 22,
                        color: notifire.getGry500_600Color))),
          ),
          hintStyle: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifire.getGry700_300Color)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifire.getGry700_300Color)),
        ),
      ),
    );
  }

  Widget _buildAppbar({required double width}) {
    return width < 500
        ? Column(
            children: [
              Text("Invoices: INV999XYZ",
                  style: Typographyy.heading4.copyWith(
                    color: notifire.getTextColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1),
              const SizedBox(
                height: 20,
              ),
              _buildSaveDraft()
            ],
          )
        : Row(
            children: [
              Text("Invoices: INV999XYZ",
                  style: Typographyy.heading4.copyWith(
                    color: notifire.getTextColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1),
              const Spacer(),
              _buildSaveDraft()
            ],
          );
  }

  Widget _buildSaveDraft() {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Container(
          height: 48,
          width: 168,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notifire.getGry50_800Color,
          ),
          child: Center(
              child: Text(
            "Save Draft",
            style: Typographyy.bodyLargeExtraBold.copyWith(color: priMeryColor),
          ))),
    );
  }
}
