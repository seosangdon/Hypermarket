import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastcampus_market/login/provider/login_provider.dart';
import 'package:fastcampus_market/main.dart';
import 'package:fastcampus_market/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.product.title}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 320,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      image: DecorationImage(
                          image: NetworkImage(
                            widget.product.imgUrl ?? '',
                          ),
                          fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          switch (widget.product.isSale) {
                            true => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.red,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                child: const Text(
                                  '할인중',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            _ => Container()
                          }
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.product.title ?? '하이퍼 플러터',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Text('리뷰 등록'),
                                    onTap: () {
                                      int reviewScore = 0;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          TextEditingController reviewTec =
                                              TextEditingController();
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return AlertDialog(
                                              title: Text('리뷰 등록'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: reviewTec,
                                                  ),
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (index) => IconButton(
                                                        onPressed: () {
                                                          setState(
                                                            () => reviewScore =
                                                                index,
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.star,
                                                          color: index <=
                                                                  reviewScore
                                                              ? Colors.orange
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text('취소'),
                                                ),
                                                Consumer(builder:
                                                    (context, ref, child) {
                                                  final user = ref.watch(
                                                      userCredentialProvider);
                                                  return TextButton(
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'products')
                                                          .doc(
                                                              '${widget.product.docId}')
                                                          .collection('reviews')
                                                          .add(
                                                        {
                                                          'uid':
                                                              user?.user?.uid ??
                                                                  '',
                                                          'email': user?.user
                                                                  ?.email ??
                                                              '',
                                                          'review': reviewTec
                                                              .text
                                                              .trim(),
                                                          'timestamp':
                                                              Timestamp.now(),
                                                          'score':
                                                              reviewScore + 1,
                                                        },
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('등록'),
                                                  );
                                                })
                                              ],
                                            );
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                        const Text('제품 상세 정보'),
                        Text('${widget.product.description}'),
                        Row(
                          children: [
                            Text(
                              '${widget.product.price ?? '100000'}원',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            Text('4.5')
                          ],
                        )
                      ],
                    ),
                  ),
                  DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(tabs: [
                            Tab(
                              text: '제품 상세',
                            ),
                            Tab(
                              text: '리뷰',
                            ),
                          ]),
                          SizedBox(
                            height: 500,
                            child: TabBarView(children: [
                              Container(
                                child:  Text('제품 상세'),
                              ),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('products')
                                      .doc('${widget.product.docId}')
                                      .collection('reviews')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final items = snapshot.data?.docs ?? [];
                                      return ListView.separated(
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('${items[index].data()['review']}'),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.orange,
                                                      ),
                                                  Text('${items[index].data()['score']}')
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (_, __) =>
                                              Divider(),
                                          itemCount: items.length);
                                    }
                                    return Container(
                                      child: CircularProgressIndicator(),
                                    );
                                  }),
                            ]),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final db = FirebaseFirestore.instance;
              final dupItems = await db
                  .collection('cart')
                  .where('uid', isEqualTo: userCredential?.user?.uid ?? '')
                  .where('product.docId', isEqualTo: widget.product.docId)
                  .get();
              if (dupItems.docs.isNotEmpty) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text('장바구니에 이미 등록되어 있는 제품입니다.'),
                    ),
                  );
                }
                return;
              }
              try {
                // 장바구니 추가
                await db.collection('cart').add({
                  'uid': userCredential?.user?.uid ?? '',
                  'email': userCredential?.user?.email ?? '',
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'product': widget.product.toJson(),
                  'cont': 1
                });

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text('장바구니에 등록 완료'),
                    ),
                  );
                }
              } catch (e) {
                // 에러 처리
                print('에러 발생: $e');
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text('장바구니 추가 중 오류가 발생했습니다.'),
                  ),
                );
              }
            },
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red[100],
              ),
              child: const Center(
                child: Text(
                  '장바구니',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
