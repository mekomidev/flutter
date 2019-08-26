// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'theme.dart';

// Standard iOS 11 tab bar height.
const double _kTabBarHeight = 49.0;
const double _kTabBarCompactHeight = 32.0;

const Color _kDefaultTabBarBorderColor = Color(0x4C000000);

/// An iOS-styled bottom navigation tab bar.
///
/// Displays multiple tabs using [BottomNavigationBarItem] with one tab being
/// active, the first tab by default.
///
/// This [StatelessWidget] doesn't store the active tab itself. You must
/// listen to the [onTap] callbacks and call `setState` with a new [currentIndex]
/// for the new selection to reflect. This can also be done automatically
/// by wrapping this with a [CupertinoTabScaffold].
///
/// Tab changes typically trigger a switch between [Navigator]s, each with its
/// own navigation stack, per standard iOS design. This can be done by using
/// [CupertinoTabView]s inside each tab builder in [CupertinoTabScaffold].
///
/// If the given [backgroundColor]'s opacity is not 1.0 (which is the case by
/// default), it will produce a blurring effect to the content behind it.
///
/// When used as [CupertinoTabScaffold.tabBar], by default `CupertinoTabBar` has
/// its text scale factor set to 1.0 and does not respond to text scale factor
/// changes from the operating system, to match the native iOS behavior. To override
/// this behavior, wrap each of the `navigationBar`'s components inside a [MediaQuery]
/// with the desired [MediaQueryData.textScaleFactor] value. The text scale factor
/// value from the operating system can be retrieved in many ways, such as querying
/// [MediaQuery.textScaleFactorOf] against [CupertinoApp]'s [BuildContext].
///
/// See also:
///
///  * [CupertinoTabScaffold], which hosts the [CupertinoTabBar] at the bottom.
///  * [BottomNavigationBarItem], an item in a [CupertinoTabBar].
class CupertinoTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a tab bar in the iOS style.
  const CupertinoTabBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor = CupertinoColors.inactiveGray,
    this.iconSize = 34.0,
    this.wideIconSize = 30.0,
    this.compactIconSize = 22.0,
    this.isWide = false,
    this.isCompact = false,
    this.border = const Border(
      top: BorderSide(
        color: _kDefaultTabBarBorderColor,
        width: 0.0, // One physical pixel.
        style: BorderStyle.solid,
      ),
    ),
  }) : assert(items != null),
       assert(
         items.length >= 2,
         "Tabs need at least 2 items to conform to Apple's HIG",
       ),
       assert(currentIndex != null),
       assert(0 <= currentIndex && currentIndex < items.length),
       assert(iconSize != null),
       assert(inactiveColor != null),
       assert(isWide != null),
       assert(isCompact != null),
       super(key: key);

  /// The interactive items laid out within the bottom navigation bar.
  ///
  /// Must not be null.
  final List<BottomNavigationBarItem> items;

  /// The callback that is called when a item is tapped.
  ///
  /// The widget creating the bottom navigation bar needs to keep track of the
  /// current index and call `setState` to rebuild it with the newly provided
  /// index.
  final ValueChanged<int> onTap;

  /// The index into [items] of the current active item.
  ///
  /// Must not be null and must inclusively be between 0 and the number of tabs
  /// minus 1.
  final int currentIndex;

  /// The background color of the tab bar. If it contains transparency, the
  /// tab bar will automatically produce a blurring effect to the content
  /// behind it.
  ///
  /// Defaults to [CupertinoTheme]'s `barBackgroundColor` when null.
  final Color backgroundColor;

  /// The foreground color of the icon and title for the [BottomNavigationBarItem]
  /// of the selected tab.
  ///
  /// Defaults to [CupertinoTheme]'s `primaryColor` if null.
  final Color activeColor;

  /// The foreground color of the icon and title for the [BottomNavigationBarItem]s
  /// in the unselected state.
  ///
  /// Defaults to [CupertinoColors.inactiveGray] and cannot be null.
  final Color inactiveColor;

  /// The size of all of the [BottomNavigationBarItem] icons.
  ///
  /// This value is used to configure the [IconTheme] for the navigation bar.
  /// When a [BottomNavigationBarItem.icon] widget is not an [Icon] the widget
  /// should configure itself to match the icon theme's size and color.
  ///
  /// Must not be null.
  final double iconSize;

  /// Same as `iconSize`, but applies when `isWide` is true
  final double wideIconSize;

  /// Same as `iconSize`, but applies when `isWide` and `isCompact` are both true
  final double compactIconSize;

  /// Controls whether the buttons should have a wide appearance, which, as of iOS 11,
  /// is common apps in landscape mode (iPhone) or always on iPad.
  /// (source: https://developer.apple.com/videos/play/wwdc2017/204/)
  ///
  /// It is suggested to wrap this widget in a [OrientationBuilder] to control the width of buttons on iPhone.
  ///
  /// The default value is false.
  final bool isWide;

  /// Controls whether the tab bar should be displayed in its compact mode (landscape mode on iPhone) or the regular one.
  ///
  /// Its value is ignored when `isWide` equals false.
  ///
  /// The default value is false.
  final bool isCompact;

  /// The border of the [CupertinoTabBar].
  ///
  /// The default value is a one physical pixel top border with grey color.
  final Border border;

  @override
  Size get preferredSize => isCompact ? const Size.fromHeight(_kTabBarCompactHeight) : const Size.fromHeight(_kTabBarHeight);

  /// Indicates whether the tab bar is fully opaque or can have contents behind
  /// it show through it.
  bool opaque(BuildContext context) {
    final Color backgroundColor =
        this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;
    return backgroundColor.alpha == 0xFF;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        border: border,
        color: backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: SizedBox(
        height: (isWide && isCompact ? _kTabBarCompactHeight : _kTabBarHeight) + bottomPadding,
        child: IconTheme.merge( // Default with the inactive state.
          data: IconThemeData(
            color: inactiveColor,
            size: isWide ? (isCompact ? compactIconSize : wideIconSize) : iconSize,
          ),
          child: DefaultTextStyle( // Default with the inactive state.
            style: (isWide ?
              CupertinoTheme.of(context).textTheme.tabWideLabelTextStyle
              : CupertinoTheme.of(context).textTheme.tabLabelTextStyle).copyWith(color: inactiveColor),
            child: Padding(
              padding: isWide && isCompact ? EdgeInsets.only(top: 4.0, bottom: bottomPadding) : EdgeInsets.only(bottom: bottomPadding),
              child: _buildTabItems(context),
            ),
          ),
        ),
      ),
    );

    if (!opaque(context)) {
      // For non-opaque backgrounds, apply a blur effect.
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: result,
        ),
      );
    }

    return result;
  }

  Widget _buildTabItems(BuildContext context) {
    final List<Widget> result = <Widget>[];

    for (int index = 0; index < items.length; index += 1) {
      final bool active = index == currentIndex;
      result.add(
        _wrapActiveItem(
          context,
          Expanded(
            child: Semantics(
              selected: active,
              // TODO(xster): This needs localization support. https://github.com/flutter/flutter/issues/13452
              hint: 'tab, ${index + 1} of ${items.length}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () { onTap(index); },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: isWide ? _buildSingleWideTabItem(items[index], active) : _buildSingleTabItem(items[index], active)
                ),
              ),
            ),
          ),
          active: active,
        ),
      );
    }

    return Row(
      // Align bottom since we want the labels to be aligned.
      // Wide items however need to be center-aligned
      crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: result,
    );
  }

  Widget _buildSingleTabItem(BottomNavigationBarItem item, bool active) {
    final List<Widget> components = <Widget>[
      Expanded(
        child: Center(child: active ? item.activeIcon : item.icon),
      ),
    ];

    if (item.title != null) {
      components.add(item.title);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: components
    );
  }

  Widget _buildSingleWideTabItem(BottomNavigationBarItem item, bool active) {
    final List<Widget> components = <Widget>[
      active ? item.activeIcon : item.icon,
    ];

    if (item.title != null) {
      components.add(
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: item.title,
        )
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: components
    );
  }

  /// Change the active tab item's icon and title colors to active.
  Widget _wrapActiveItem(BuildContext context, Widget item, { @required bool active }) {
    if (!active)
      return item;

    final Color activeColor = this.activeColor ?? CupertinoTheme.of(context).primaryColor;
    return IconTheme.merge(
      data: IconThemeData(color: activeColor),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: activeColor),
        child: item,
      ),
    );
  }

  /// Create a clone of the current [CupertinoTabBar] but with provided
  /// parameters overridden.
  CupertinoTabBar copyWith({
    Key key,
    List<BottomNavigationBarItem> items,
    Color backgroundColor,
    Color activeColor,
    Color inactiveColor,
    Size iconSize,
    Size wideIconSize,
    Size compactIconSize,
    bool isWide,
    bool isCompact,
    Border border,
    int currentIndex,
    ValueChanged<int> onTap,
  }) {
    return CupertinoTabBar(
      key: key ?? this.key,
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      iconSize: iconSize ?? this.iconSize,
      wideIconSize: wideIconSize ?? this.wideIconSize,
      compactIconSize: compactIconSize ?? this.compactIconSize,
      isWide: isWide ?? this.isWide,
      isCompact: isCompact ?? this.isCompact,
      border: border ?? this.border,
      currentIndex: currentIndex ?? this.currentIndex,
      onTap: onTap ?? this.onTap,
    );
  }
}
