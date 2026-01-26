// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/invoicescontroller.dart';
import '../../controller/recipients_controller.dart';


class Recipients extends StatefulWidget {
  const Recipients({super.key});

  @override
  State<Recipients> createState() => _RecipientsState();
}

class _RecipientsState extends State<Recipients> {
  RecipientsController recipientsController = Get.put(RecipientsController());
  ColorNotifire notifire = ColorNotifire();
  InvoiceController invoiceController = Get.put(InvoiceController());
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(15),
      color: notifire.getBgColor,
      child:  LayoutBuilder(
        builder: (context, constraints){
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),
                        decoration: InputDecoration(
                          prefixIcon: SizedBox(
                              height: 22,
                              width: 22,
                              child: Center(child: SvgPicture.asset("assets/images/Search.svg",height: 20,width: 20,color: notifire.getTextColor,))),
                          hintText: "Search by Recipients...",
                          hintStyle: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
                          isDense: true,
                          border:          OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                          disabledBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                          focusedBorder:   OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                          enabledBorder:   OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)),borderSide: BorderSide(color: notifire.getGry700_300Color)),


                      ),),
                    ),
                    constraints.maxWidth<800? const SizedBox() : const Spacer(),
                    constraints.maxWidth<800? const SizedBox() : _addNew(),
                    const SizedBox(width: 16,),
                    constraints.maxWidth<800? const SizedBox() : _filters(),

                  ],
                ),
                const SizedBox( height: 16,),
                constraints.maxWidth<800 ?  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   _addNew() ,
                    const SizedBox(width: 16,),
                   _filters()  ,
                  ],
                ) : const SizedBox(),

                SizedBox(
                  height: Get.height + (constraints.maxWidth<600? 110 : -150),
                  width: constraints.maxWidth,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth<1400 ? 1500 : constraints.maxWidth,
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                              Table(
                              children: [
                              TableRow(
                                  children: [
                                // Divider(
                                //   color: notifire.getGry700_300Color,height: 30,
                                // ),
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
                              TableRow(
                                  children: [
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
                              ]),
                                for (var a = invoiceController.loadmore; a < invoiceController.loadmore + invoiceController.selectindex; a++)
                                TableRow(
                                    children: [

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
                                                      color: notifire
                                                          .getGry700_300Color)),
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
                )





              ],
            ),
          );
        }
      ),
    );
  }

  Future _dialog(){
    return showDialog(
      context: context, builder: (context) {
      return GetBuilder<RecipientsController>(
        builder: (recipientsController) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: notifire.getContainerColor,
           insetPadding: const EdgeInsets.symmetric(horizontal: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          content: Row(
            children: [
              Flexible(
                child: SizedBox(
                  // height: 400,
                  width: 450,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                              Text("Add Recipient",style: Typographyy.heading6.copyWith(color: notifire.getTextColor),),
                              const Spacer(),
                              InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: SvgPicture.asset("assets/images/plus.svg",height: 20,width: 20,color: priMeryColor,)),

                            ],),
                          ),

                          Divider(color: notifire.getGry700_300Color,height: 32,),
                          const SizedBox(height: 16,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Currency",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getGry500_600Color),),
                                  const SizedBox(height: 12,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PopupMenuButton(
                                          tooltip: "",
                                          onOpened: () {
                                            recipientsController.setIsCurrency(true);
                                          },
                                          onCanceled: () {
                                            recipientsController.setIsCurrency(false);
                                          },
                                          offset: const Offset(0, 50),
                                          color: notifire.getContainerColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: notifire.getGry700_300Color),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(backgroundColor: Colors.transparent,radius: 12, child: SvgPicture.asset(recipientsController.currencyLogo[recipientsController.currencySelect])),
                                                const SizedBox(width: 8,),
                                                Text(recipientsController.currency[recipientsController.currencySelect],style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),),
                                                const Spacer(),
                                                SvgPicture.asset( recipientsController.isCurrency? "assets/images/chevron-up.svg" : "assets/images/chevron-down.svg",height: 20,width: 20),
                                              ],
                                            ),
                                          ),
                                          itemBuilder: (context) {
                                          return [
                                             PopupMenuItem(
                                               padding: EdgeInsets.zero,
                                                 child: SizedBox(
                                                   height: 180,
                                                   width: 150,
                                                   child: ListView.builder(
                                                     physics: const NeverScrollableScrollPhysics(),
                                                     shrinkWrap: true,
                                                     itemCount: recipientsController.currencyLogo.length,
                                                     itemBuilder: (context, index) {
                                                       return ListTile(
                                                         dense: true,
                                                         onTap: () {
                                                           recipientsController.setCurrencySelect(index);
                                                           Get.back();
                                                         },
                                                         leading: CircleAvatar(backgroundColor: Colors.transparent,radius: 12, child: SvgPicture.asset(recipientsController.currencyLogo[index])),
                                                         title: Text(recipientsController.currency[index],style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                                                       );

                                                   },),

                                                 )),
                                          ];

                                        },),
                                      ),

                                    ],
                                  )

                                ],
                              ),
                                const SizedBox(height: 24,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Recipient type",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getGry500_600Color),),
                                    const SizedBox(height: 12,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PopupMenuButton(
                                            tooltip: "",
                                            onOpened: () {
                                              recipientsController.setIsRecipientsType(true);
                                            },
                                            onCanceled: () {
                                              recipientsController.setIsRecipientsType(false);
                                            },
                                            offset: const Offset(0, 50),
                                            color: notifire.getContainerColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              height: 42,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: notifire.getGry700_300Color),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(recipientsController.type[recipientsController.typeSelect],style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),),
                                                  const Spacer(),
                                                  SvgPicture.asset( recipientsController.isRecipientsType? "assets/images/chevron-up.svg" : "assets/images/chevron-down.svg",height: 20,width: 20),
                                                ],
                                              ),
                                            ),
                                            itemBuilder: (context) {
                                              return [
                                                PopupMenuItem(
                                                    padding: EdgeInsets.zero,
                                                    child: SizedBox(
                                                      height: 100,
                                                      width: 150,
                                                      child: ListView.builder(
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: recipientsController.type.length,
                                                        itemBuilder: (context, index) {
                                                          return ListTile(
                                                            dense: true,
                                                            onTap: () {
                                                              recipientsController.setTypeSelect(index);
                                                              Get.back();
                                                            },
                                                            title: Text(recipientsController.type[index],style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                                                          );

                                                        },),
                                                    )
                                                ),
                                              ];

                                            },),
                                        ),

                                      ],
                                    )

                                  ],
                                ),
                                const SizedBox(height: 24,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Email",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getGry500_600Color),),
                                    const SizedBox(height: 12,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: notifire.getGry700_300Color),
                                            ),
                                            child: Center(child: TextField(style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),decoration: const InputDecoration(border: InputBorder.none,isDense: true,contentPadding: EdgeInsets.all(0)))),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Full name of the account holder",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getGry500_600Color),),
                                    const SizedBox(height: 12,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: notifire.getGry700_300Color),
                                            ),
                                            child: Center(child: TextField(style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),decoration: const InputDecoration(border: InputBorder.none,isDense: true,contentPadding: EdgeInsets.all(0)))),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24,),
                                Text("Bank Details",style: Typographyy.heading6.copyWith(color: notifire.getTextColor),),
                                Divider(color: notifire.getGry700_300Color,height: 32,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("IBN",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getGry500_600Color),),
                                        const SizedBox( width: 8),
                                        SvgPicture.asset("assets/images/question-circle-outlined.svg",height: 20,width: 20,color:  notifire.getGry500_600Color),
                                      ],
                                    ),
                                    const SizedBox(height: 12,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: notifire.getGry700_300Color),
                                            ),
                                            child: Center(child: TextField(style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),decoration: const InputDecoration(border: InputBorder.none,isDense: true,contentPadding: EdgeInsets.all(0)))),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: priMeryColor,
                                            fixedSize: const Size.fromHeight(48),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () {}, child: Text("Confirm",style: Typographyy.bodyMediumExtraBold.copyWith(color: Colors.white),)),
                                    ),
                                  ],
                                )

                              ],
                            ),
                          )
                     ]
                    ),
                  ),
                ),
              ),
            ],
          ),

          );
        }
      );
    },);

  }


  Widget _addNew(){
    return  ElevatedButton(
        style:
        ElevatedButton.styleFrom(elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
            fixedSize: const Size.fromHeight(42)),
        onPressed: () {
          _dialog();
        },
        child: Row(children: [SvgPicture.asset("assets/images/plus+.svg",height: 20,width: 20,color: Colors.white),  const SizedBox(width: 8,), Text("Add New",style: Typographyy.bodyMediumExtraBold.copyWith(color: Colors.white),)],));
  }

  Widget _filters(){
    return  ElevatedButton(style:
    ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
      fixedSize: const Size.fromHeight(42),
      backgroundColor: notifire.getBgColor,
      side: BorderSide(color: notifire.getGry700_300Color),
    ),
        onPressed: () {},
        child: Row(children: [SvgPicture.asset("assets/images/Filter.svg",height: 20,width: 20,color: notifire.getTextColor),  const SizedBox(width: 8,), Text("Filters",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getTextColor),)],));
  }
  Widget dataColumn1(
      {required String title,
        required String iconpath,
        required bool iscenter}) {
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


  Widget _buildRow({required String iconpath,required String title}){
    return Row(
      children: [
        SvgPicture.asset(iconpath,width: 20,height: 20,color: notifire.getGry500_600Color),
        const SizedBox(width: 10,),
        Text(title,style: Typographyy.bodySmallSemiBold.copyWith(color: notifire.getGry500_600Color)),

      ],);
  }
  
  // ignore: body_might_complete_normally_nullable
  Color? colorWithOpacity(Color priMeryColor, double d) {}


}
