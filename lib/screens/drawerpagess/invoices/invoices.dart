// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/invoicescontroller.dart';
import 'invoices_create.dart';

class Invoices extends StatefulWidget {
  const Invoices({super.key});

  @override
  State<Invoices> createState() => _InvoicesState();
}

class _InvoicesState extends State<Invoices> {
  ColorNotifire notifire = ColorNotifire();
  InvoiceController invoiceController = Get.put(InvoiceController());

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<InvoiceController>(
      builder: (invoiceController) {
        return LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire.getBgColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding:  EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                           height: Get.height- (constraints.maxWidth<800? 0:50),
                           width: constraints.maxWidth,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth<1400 ? 1500 : constraints.maxWidth,
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: notifire.getGry700_300Color)),
                                                  height: 48,
                                                  width: 295,
                                                  child: Center(
                                                    child: TextField(
                                                      style:
                                                      Typographyy.bodyMediumMedium.copyWith(
                                                        color: notifire.getTextColor,
                                                      ),
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          contentPadding:  EdgeInsets.only(top: constraints.maxWidth<600?  15 : 17),
                                                          prefixIcon: SizedBox(
                                                              height: 20,
                                                              width: 20,
                                                              child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/images/Search.svg",
                                                                    color: notifire.getTextColor,
                                                                    height: 20,
                                                                    width: 20,
                                                                  ))),
                                                          hintText: "Search invoice...",
                                                          border: InputBorder.none,
                                                          hintStyle: Typographyy.bodyMediumMedium
                                                              .copyWith(
                                                              color: notifire
                                                                  .getGry500_600Color)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 940,
                                                ),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Get.to(const InvoicesCreate());
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            fixedSize: const Size.fromHeight(48),
                                                            backgroundColor: priMeryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(12))),
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/images/receipt-edit.svg",
                                                              height: 20,
                                                              width: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "Create invoice",
                                                              style: Typographyy
                                                                  .bodyMediumExtraBold
                                                                  .copyWith(color: whiteColor),
                                                            ),
                                                          ],
                                                        )),
                                                    const SizedBox(
                                                      width: 16,
                                                    ),
                                                    OutlinedButton(
                                                        onPressed: () {},
                                                        style: OutlinedButton.styleFrom(
                                                            fixedSize: const Size.fromHeight(48),
                                                            side: BorderSide(
                                                                color:
                                                                notifire.getGry700_300Color),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(12))),
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/images/Filter.svg",
                                                                height: 20,
                                                                width: 20,
                                                                color: notifire.getTextColor),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "Filters",
                                                              style: Typographyy
                                                                  .bodyMediumExtraBold
                                                                  .copyWith(
                                                                  color:
                                                                  notifire.getTextColor),
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Table(
                                              columnWidths: const {
                                                0: FixedColumnWidth(50),
                                                 5: FixedColumnWidth(230),

                                              },
                                              children: [
                                                TableRow(children: [
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                ]),
                                                TableRow(children: [
                                                  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Checkbox(
                                                      side: BorderSide(
                                                          color: notifire.getGry600_500Color),
                                                      shape: CircleBorder(
                                                          side: BorderSide(
                                                              color: notifire.getGry600_500Color)),
                                                      value: invoiceController.checkboxis,
                                                      onChanged: (value) {
                                                        invoiceController.setchekboxis(
                                                            invoiceController.checkboxis =
                                                            !invoiceController.checkboxis);
                                                        if (invoiceController.checkboxis ==
                                                            true) {
                                                          for (var a = 0; a <= invoiceController.listtiletitle.length; a++) {
                                                            invoiceController.checkBoxs.add(a);
                                                          }
                                                        } else {
                                                          invoiceController.checkBoxs.clear();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  dataColumn1(
                                                      title: "Name",
                                                      iconpath:
                                                      "assets/images/arrows-down-up.svg",
                                                      iscenter: false),
                                                  dataColumn1(
                                                      title: "Date",
                                                      iconpath:
                                                      "assets/images/arrows-down-up.svg",
                                                      iscenter: false),
                                                  dataColumn1(
                                                      title: "Client",
                                                      iconpath:
                                                      "assets/images/arrows-down-up.svg",
                                                      iscenter: false),
                                                  dataColumn1(
                                                      title: "Price",
                                                      iconpath:
                                                      "assets/images/arrows-down-up.svg",
                                                      iscenter: false),
                                                  Center(
                                                    child: dataColumn1(
                                                        title: "Status",
                                                        iconpath:
                                                        "assets/images/arrows-down-up.svg",
                                                        iscenter: true),
                                                  ),
                                                  Center(
                                                    child: dataColumn1(
                                                        title: "Actions",
                                                        iconpath:
                                                        "assets/images/arrows-down-up.svg",
                                                        iscenter: true),
                                                  ),
                                                ]),
                                                TableRow(children: [
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                  Divider(
                                                    color: notifire.getGry700_300Color,height: 30,
                                                  ),
                                                ]),
                                                for (var a = invoiceController.loadmore; a < invoiceController.loadmore + invoiceController.selectindex; a++)
                                                  TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:  const EdgeInsets.symmetric(vertical:  25),
                                                          child: Center(
                                                            child: SizedBox(
                                                                height: 22,
                                                                width: 22,
                                                                child: Checkbox(
                                                                  side: BorderSide(
                                                                      color: notifire
                                                                          .getGry600_500Color),
                                                                  shape: CircleBorder(
                                                                      side: BorderSide(
                                                                          color: notifire
                                                                              .getGry600_500Color)),
                                                                  value: invoiceController.checkBoxs.contains(a) ? true : false,
                                                                  onChanged: (value) {
                                                                    invoiceController.selcetcheckbox(a);
                                                                  },
                                                                )),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 8),
                                                          child: ListTile(
                                                            title: Text(
                                                                invoiceController.listtiletitle[a],
                                                                style: Typographyy.bodyLargeMedium
                                                                    .copyWith(
                                                                    color:
                                                                    notifire.getTextColor)),
                                                            leading: CircleAvatar(
                                                                radius: 24,
                                                                backgroundColor:
                                                                colorWithOpacity(priMeryColor, 0.2),
                                                                child: SvgPicture.asset(
                                                                  "assets/images/receipt1.svg",
                                                                  height: 22,
                                                                  width: 22,
                                                                )),
                                                            dense: true,
                                                            contentPadding: const EdgeInsets.all(0),
                                                            subtitle: Padding(
                                                              padding:
                                                              const EdgeInsets.only(top: 10.0),
                                                              child: Text("INV110XXX",
                                                                  style: Typographyy
                                                                      .bodyMediumMedium
                                                                      .copyWith(
                                                                      color: notifire
                                                                          .getGry500_600Color)),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 20),
                                                          child: Text(invoiceController.date[a],
                                                              style: Typographyy.bodyLargeSemiBold
                                                                  .copyWith(
                                                                  color:
                                                                  notifire.getTextColor)),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 20),
                                                          child: Text(invoiceController.clint[a],
                                                              style: Typographyy.bodyLargeSemiBold
                                                                  .copyWith(
                                                                  color:
                                                                  notifire.getTextColor)),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 20),
                                                          child: Text(invoiceController.price[a],
                                                              style: Typographyy.bodyLargeExtraBold
                                                                  .copyWith(
                                                                  color:
                                                                  notifire.getTextColor)),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10),
                                                          child: Center(
                                                            child: Container(
                                                                height: 40,
                                                                width: 96,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                  BorderRadius.circular(8),
                                                                  color: colorWithOpacity(invoiceController
                                                                      .iteamcolor[a], 0.10),
                                                                ),
                                                                child: Center(
                                                                    child: Text(
                                                                        invoiceController.status[a],
                                                                        style: Typographyy
                                                                            .bodyMediumMedium
                                                                            .copyWith(
                                                                            color: invoiceController
                                                                                .iteamcolor[a])))),
                                                          ),
                                                        ),
                                                        PopupMenuButton(
                                                          tooltip: "",
                                                          color: notifire.getDrawerColor,
                                                          offset: const Offset(30,52),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(
                                                                right: 20, top: 20, bottom: 20),
                                                            child: Center(
                                                              child: Container(
                                                                height: 30,
                                                                width: 30,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.circular(8),
                                                                    color: Colors.transparent,
                                                                    border: Border.all(
                                                                        color: notifire.getGry700_300Color)),
                                                                child: Center(
                                                                    child: SvgPicture.asset(
                                                                      "assets/images/dots-vertical.svg",
                                                                      height: 20,
                                                                      width: 20,
                                                                    )),
                                                              ),
                                                            ),
                                                          ),
                                                          itemBuilder: (context) {
                                                            return [
                                                              PopupMenuItem(
                                                                  padding: const EdgeInsets.all(8),
                                                                  child: Column(
                                                                    children: [
                                                                      _buildRow(iconpath: "assets/images/copy.svg", title: "Copy"),
                                                                      const SizedBox(height: 8,),
                                                                      _buildRow(iconpath: "assets/images/printer.svg", title: "Print"),
                                                                      const SizedBox(height: 8,),
                                                                      _buildRow(iconpath: "assets/images/file-download.svg", title: "Download PDF"),
                                                                      const SizedBox(height: 8,),
                                                                      _buildRow(iconpath: "assets/images/share-two.svg", title: "Share Link"),
                                                                      const SizedBox(height: 8,),
                                                                      _buildRow(iconpath: "assets/images/archive.svg", title: "Archive"),

                                                                    ],
                                                                  ))
                                                            ];
                                                          },
                                                        ),
                                                      ]),
                                              ],
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
                      ],
                    ),
                  ),
                  GetBuilder<InvoiceController>(
                      builder: (invoiceController) {
                    return Row(
                      children: [
                        Expanded(
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal:  15 ,vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Show result:",
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(
                                            color: notifire.getGry600_500Color),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  PopupMenuButton(
                                    tooltip: "",
                                    offset: const Offset(0, -50),
                                    constraints: const BoxConstraints(
                                        maxWidth: 60, minWidth: 60,maxHeight: 120,minHeight: 120),
                                    onOpened: () {
                                      invoiceController.setmenuu(true);
                                    },
                                    onCanceled: () {
                                      invoiceController.setmenuu(false);
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    color: notifire.getDrawerColor,
                                    child: Container(
                                      height: 37,
                                      width: 68,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color:
                                                  notifire.getGry700_300Color)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              invoiceController.selectindex
                                                  .toString(),
                                              style: Typographyy
                                                  .bodyMediumExtraBold
                                                  .copyWith(
                                                      color: notifire
                                                          .getTextColor),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SvgPicture.asset(invoiceController
                                                    .ismenuopen
                                                ? "assets/images/chevron-up.svg"
                                                : "assets/images/chevron-down.svg"),
                                          ]),
                                    ),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                            enabled: false,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      invoiceController
                                                          .setindexforitem(5);
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "5",
                                                      style: Typographyy
                                                          .bodyMediumExtraBold
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      invoiceController
                                                          .setindexforitem(6);
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "6",
                                                      style: Typographyy
                                                          .bodyMediumExtraBold
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      invoiceController.setindexforitem(7);
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "7",
                                                      style: Typographyy
                                                          .bodyMediumExtraBold
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      invoiceController.setindexforitem(10);
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "10",
                                                      style: Typographyy
                                                          .bodyMediumExtraBold
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                    )),
                                              ],
                                            )),
                                      ];
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        invoiceController.scrollController.animateTo(-40, duration: const Duration(milliseconds: 1000), curve: Curves.bounceOut);
                                      },
                                      child: SvgPicture.asset("assets/images/chevron-left.svg",height: 20,width: 20,)),
                                  SizedBox(
                                    height: 37,
                                    width: 140,
                                    child: Center(
                                      child: ListView.builder(
                                        controller: invoiceController.scrollController,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 5,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              invoiceController.setloadmore(invoiceController.selectpage);
                                              invoiceController.setpage(index);
                                            },

                                            child: Container(
                                                width: 37,
                                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: invoiceController.selectpage == index? priMeryColor : notifire.getGry700_300Color),
                                                    color: Colors.transparent
                                                ),
                                                child: Center(child: Text("$index",style: Typographyy.bodySmallSemiBold.copyWith(color: invoiceController.selectpage == index? priMeryColor : notifire.getGry500_600Color),))),
                                          );
                                        },),
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        invoiceController.scrollController.animateTo(10 * 100, duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
                                      },
                                      child: SvgPicture.asset("assets/images/chevron-left-1.svg",height: 20,width: 20,)),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        });
      }
    );
  }

  Widget _buildRow({required String iconpath,required String title}){
    return Row(
      children: [
        SvgPicture.asset(iconpath,width: 20,height: 20,color: notifire.getGry500_600Color),
        const SizedBox(width: 10,),
        Text(title,style: Typographyy.bodySmallSemiBold.copyWith(color: notifire.getGry500_600Color)),

      ],);
  }

  DataColumn dataColumn({required String title, required String iconpath}) {
    return DataColumn(
      label: Row(
        children: [
          Text(title,
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getGry500_600Color)),
          const SizedBox(
            width: 16,
          ),
          SizedBox(
              height: 16,
              width: 16,
              child: Center(
                  child: SvgPicture.asset(iconpath,
                      height: 22,
                      width: 22,
                      color: notifire.getGry500_600Color))),
        ],
      ),
    );
  }

  Widget dataColumn1({required String title, required String iconpath, required bool iscenter}) {
    return Row(
      mainAxisAlignment:
          iscenter ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Text(title,
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getGry500_600Color)),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
            height: 16,
            width: 16,
            child: Center(
                child: SvgPicture.asset(iconpath,
                    height: 22,
                    width: 22,
                    color: notifire.getGry500_600Color))),
      ],
    );
  }

}
