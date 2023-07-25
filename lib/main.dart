import 'dart:math';
import 'dart:ui';

import 'package:align_positioned/align_positioned.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:mylib/mylib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  static double expandedHeight = 250.0;
  static const double bottomBarHeight = 90.0;
  static const caffeUrl = 'http://spsms.dyndns.org:3100/images/caffe';

  @override
  Widget build(BuildContext context) {
    final pads = MediaQuery.of(context).viewPadding;
    final controller = useScrollController();
    final opacity = useState(0.0);
    final last = useState(0.0);

    useEffectOnce(() {
      controller.addListener(() {
        final maxExtent = expandedHeight - pads.top;
        final offset = min(controller.offset, maxExtent);

        opacity.value = offset <= 0.0
            ? 0.0
            : offset >= maxExtent
                ? 1.0
                : offset / maxExtent;
      });
      controller.addListener(() {
        final gap = controller.offset - last.value;

        last.value = switch ((controller.position.userScrollDirection, gap)) {
          (== ScrollDirection.forward, < 0.0 || >= bottomBarHeight) => 0.0,
          (== ScrollDirection.reverse, >= 10.0) => -bottomBarHeight,
          _ => last.value
        };
      });
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            controller: controller,
            slivers: [
              SliverAppBar(
                expandedHeight: expandedHeight,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: FasadeWidget(opacity: opacity),
                ),
                pinned: true,
                floating: true,
                scrolledUnderElevation: 0.0,
                bottom: BottomTabBar(opacity: opacity),
              ),
              buildSampleContainer(),
              buildHorizontalContainer(),
              buildSampleSliverList(),
            ],
          ),
          AnimatedPositioned(
            duration: 200.msecs,
            left: 0.0,
            right: 0.0,
            bottom: last.value,
            child: const BottomNavBar(),
          ),
        ],
      ),
      floatingActionButtonAnimator: FabTransitionAnimation(),
      floatingActionButtonLocation: CustomFABLocation(pos: last.value),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.animateTo(
            0.0,
            curve: Curves.easeInOutQuad,
            duration: 250.msecs,
          );
          last.value = 0.0;
        },
        extendedIconLabelSpacing: 0.0,
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        icon: const Icon(Icons.pedal_bike_rounded, size: 32.0),
        label: AnimatedSize(
          duration: 250.msecs,
          child: Container(
            width: last.value == 0.0 ? 80.0 : 0.0,
            alignment: Alignment.center,
            child: Text(
              last.value == 0.0 ? 'Delivers' : '',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
              overflow: TextOverflow.clip,
            ),
          ),
        ),
      ),
    );
  }

  SliverList buildSampleSliverList() {
    return SliverList.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 200.0,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: index.color,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            index.toString(),
            style: TextStyle(
                fontSize: 100.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade200),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter buildSampleContainer() {
    return SliverToBoxAdapter(
      child: Container(
        margin: 12.0.allInsets,
        height: 150.0,
        decoration: BoxDecoration(
            color: Colors.amber.shade300.withAlpha(200),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(1, 4),
              )
            ]),
      ),
    );
  }

  SliverToBoxAdapter buildHorizontalContainer() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: 12.0.horiInsets,
              child: const Text(
                '추천메뉴',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140.0,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(58.0),
                                child: Material(
                                  child: Ink.image(
                                    width: 120.0,
                                    height: 120.0,
                                    image: CachedNetworkImageProvider(
                                        '$caffeUrl/caffe0${1 + index}.jpg'),
                                    fit: BoxFit.cover,
                                    child: InkWell(
                                      onTap: () => (),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            '카페 아메리카노',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider()),
            )
          ],
        ),
      ),
    );
  }
}

class CustomFABLocation extends FloatingActionButtonLocation {
  const CustomFABLocation({required this.pos});

  final double pos;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    double maxHeight = scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height * 2.8;
    double y = pos == 0.0 ? maxHeight : maxHeight + 70.0;
    double x = scaffoldGeometry.scaffoldSize.width -
        (scaffoldGeometry.floatingActionButtonSize.width + 16.0);

    return Offset(x, y);
  }
}

class FabTransitionAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({
    required Offset begin,
    required Offset end,
    required double progress,
  }) {
    return Offset.lerp(begin, end, progress)!;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) =>
      Tween<double>(begin: 1.0, end: 1.0).animate(parent);

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) =>
      Tween<double>(begin: 1.0, end: 1.0).animate(parent);
}

class BottomNavBar extends HookWidget {
  const BottomNavBar({super.key, this.initIndex});

  final int? initIndex;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(initIndex ?? 0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Opacity(
          opacity: 0.7,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex.value,
            elevation: 0,
            //backgroundColor: const Color(0x00ffffff),
            //unselectedItemColor: Colors.blue,
            items: const [
              BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                  label: 'Pay', icon: Icon(Icons.credit_card)),
              BottomNavigationBarItem(label: 'Order', icon: Icon(Icons.shop)),
              BottomNavigationBarItem(
                  label: 'Other', icon: Icon(Icons.more_horiz)),
            ],
            onTap: (value) => selectedIndex.value = value,
          ),
        ),
      ),
    );
  }
}

class FasadeWidget extends StatelessWidget {
  const FasadeWidget({super.key, required this.opacity});

  final ValueNotifier<double> opacity;

  static const url = 'http://spsms.dyndns.org:3100/images/nature/nature04.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          foregroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.1),
              Color.fromRGBO(255, 255, 255, 0.2),
              Color.fromRGBO(255, 255, 255, 0.7),
              Color.fromRGBO(255, 255, 255, 1.0),
            ],
            stops: [0.3, 0.4, 0.5, 0.6],
          )),
          child: Image.network(url,
              fit: BoxFit.cover, alignment: const Alignment(0, -0.8)),
        ),
        AlignPositioned(
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: 1.0 - opacity.value,
            child: SizedBox(
              width: double.maxFinite,
              height: 150.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => (),
                    child: Container(
                      margin: 8.0.allInsets,
                      color: Colors.transparent,
                      alignment: Alignment.topRight,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '내용 보기',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w300),
                          ),
                          Icon(
                            Icons.east_outlined,
                            size: 20.0,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80.0,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 4.0),
                                    alignment: Alignment.bottomLeft,
                                    child: const Text('5★ until Green level'),
                                  ),
                                ),
                                Expanded(
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 4.0),
                                      height: 8.0,
                                      width: 220.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 1,
                          child: RichText(
                            text: TextSpan(
                                text: 0.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4.0,
                                ),
                                children: const [
                                  TextSpan(
                                      text: '/5★',
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      )),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const BottomTabBar({Key? key, required this.opacity}) : super(key: key);

  final ValueNotifier<double> opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      width: preferredSize.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(opacity.value),
            blurRadius: 3.0,
            offset: const Offset(0.0, 1.0),
          ),
          const BoxShadow(
            color: Colors.white,
            // blurRadius: 3.0,
            offset: Offset(0.0, -4.0),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => (),
            icon: const Icon(Icons.mail_lock_outlined),
            label: const Text('What\'s New'),
          ),
          TextButton.icon(
            onPressed: () => (),
            icon: const Icon(Icons.confirmation_num_outlined),
            label: const Text('Coupon'),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () => (),
                  icon: const Icon(Icons.notifications_none_outlined)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}
