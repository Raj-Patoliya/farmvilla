import 'package:farmvilla/Services/FirebaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final CollectionReference _cart = FirebaseFirestore.instance.collection("cart");
  var productData;
  var countIterator;
  var countProduct;
  var pId;
  var userData;
  @override
  void initState() {
    super.initState();
    getUserByEmail();
    getAllProdctGrid();
  }
  getUserByEmail() async{
    var result = await FirebaseFirestore.instance
        .collection("userDetails")
        .where("email", isEqualTo: UserData().email)
        .get();
    setState(() {
      userData = result.docs.single.data();
      print(result.docs[0].reference.id);
    });
  }

  getAllProdctGrid() async{
    final CollectionReference _collectionRef =  FirebaseFirestore.instance.collection('product');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List


    final QuerySnapshot queryResult = await FirebaseFirestore.instance.collection('product').get();

    setState(() {
      productData = querySnapshot.docs.map((doc) => doc.data()).toList();
      countProduct = querySnapshot.docs.length;
      countIterator = countProduct;
    });
  }
  @override
  Widget _gridItemHeader(var cnt) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          FittedBox(
            child: Text(
                productData[cnt]['pname']!,
              overflow: TextOverflow.ellipsis,
              maxLines: 100,
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 75, 73, 73)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridItemBody(var cnt) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E6E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image.network(productData[cnt]['image']),
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
             Expanded(child: Center(child: Text('\$ ${productData[cnt]['rate']}',style: TextStyle(fontSize: 20),))),
            const VerticalDivider(width: 1.0),
            Expanded(
                child: Center(
                    child: ElevatedButton(
                      onPressed: () async{
                          await _cart.add({
                            "pId" : productData[cnt]['pId'],
                            'pname':productData[cnt]['pname'],
                            "email":FirebaseAuth.instance!.currentUser!.email .toString(),
                            'image': productData[cnt]['image'],
                            'rate':productData[cnt]['rate']
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
      child: GridView.builder(
        itemCount: countProduct,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 10 / 16,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemBuilder: (_, index) {
          // Product product = controller.filteredProducts[index];
          return GridTile(
            header: _gridItemHeader(index),
            footer: _gridItemFooter(index),
            child: _gridItemBody(index),
          );
        },
      ),
    );
  }
}
