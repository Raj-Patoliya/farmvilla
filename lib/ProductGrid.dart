import 'dart:developer';

import 'package:farmvilla/Services/FirebaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
class ProductGrid extends StatefulWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  State<ProductGrid> createState() => _ProductGridState();
}
var productData;
class _ProductGridState extends State<ProductGrid> {
  final CollectionReference _cart = FirebaseFirestore.instance.collection("cart");

  var countIterator;
  var countProduct = 0;
  var pId;
  var cartItem = [];
  var cartProductId = [];
  var tempProductData=[];
  var tempProductCount=0;
  var userData;
  var newValueForSearch = '';
  @override
  void initState() {
    super.initState();
    getAllProdctGrid();
  }

  getAllProdctGrid() async{
    final CollectionReference _collectionRef =  FirebaseFirestore.instance.collection('product');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    for (var snapshot in querySnapshot.docs) {
      var documentID = snapshot.id; //
      cartItem.add(documentID);
    }
    setState(() {
      productData = querySnapshot.docs.map((doc) => doc.data()).toList();
      countProduct = querySnapshot.docs.length;
      countIterator = countProduct;
      tempProductData = productData;
      tempProductCount = countProduct;
    });
  }
  final TextEditingController _searchQuery = TextEditingController();
  onSearchGridView(String s){
    if (s.isEmpty) {
      setState(() {
        tempProductData = productData;
        tempProductCount = countProduct;
      });
    } else {
      setState(() {
        tempProductData = productData;
        tempProductData = tempProductData.where((element) =>
        element["pname"].toLowerCase().contains(s.toLowerCase()) ||
            element["pname"].toLowerCase().contains(s.toLowerCase()))
            .toList();
        tempProductCount = tempProductData.length;
      });

    }
  }

  @override
  Widget _gridItemHeader(var cnt) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.only(top: 10) ,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              FittedBox(
                child: Text(
                  tempProductData[cnt]['pname']!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 100,
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 75, 73, 73)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItemBody(var cnt) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E6E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: SizedBox(
            height: 60,
            width: 60,
            child: Image.network(tempProductData[cnt]['image'],fit: BoxFit.cover,)),
      ),

    );
  }

  Widget _gridItemFooter(var cnt) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Expanded(child: Center(child: Text('\$ ${tempProductData[cnt]['rate']}',style: TextStyle(fontSize: 20),))),
            const VerticalDivider(width: 1.0),
            Expanded(
                child: Center(
                    child: ElevatedButton(
                      onPressed: () async{
                        await _cart.add({
                          "pId" : cartItem[cnt],
                          'pname':tempProductData[cnt]['pname'],
                          "email":FirebaseAuth.instance!.currentUser!.email .toString(),
                          'image': tempProductData[cnt]['image'],
                          'rate':tempProductData[cnt]['rate']
                        });
                      },
                      child:const Text("Add"),
                    ))),
          ],
        ),

      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child:
      Column(
        children: [

          TextField(
            controller: _searchQuery,
            decoration: InputDecoration(
              hintText: 'Enter a message',

            ),
            onChanged: (value) {
              setState(() {
                onSearchGridView(value);
              });
            },
      ),


          // Container(child: Row(
          //   children: [
          //     ElevatedButton(onPressed: (){}, child: Text("Jai Siya Ram")),
          //     Padding(padding: EdgeInsets.all(10)),
          //     ElevatedButton(onPressed: (){}, child: Text("Jai Siya Ram"))
          //   ],
          // ),),
          Flexible(
            child: GridView.builder(
              itemCount: tempProductCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 10 / 16,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10),
              itemBuilder: (_, index) {
                // Product product = controller.filteredProducts[index];
                return tempProductCount == 0 ? const Center(child:  CircularProgressIndicator(),) : GridTile(
                  header: _gridItemHeader(index),
                  footer: _gridItemFooter(index),
                  child: _gridItemBody(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}