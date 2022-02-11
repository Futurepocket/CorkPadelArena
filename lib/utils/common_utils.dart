import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/src/widgets.dart';
import 'package:cork_padel_arena/view/shoppingCart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool loggedInBefore = false;

Future<void> currentUser() {
  final user = FirebaseAuth.instance.currentUser;
  final String _email = user!.email.toString();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(_email)
      .get()
      .then((value) {
    Userr().name = value.data()!["first_name"].toString();
    Userr().email = value.data()!["email"].toString();
    Userr().address = value.data()!["address"].toString();
    Userr().surname = value.data()!["last_name"].toString();
    Userr().phoneNbr = value.data()!["phoneNbr"].toString();
    Userr().city = value.data()!["city"].toString();
    Userr().id = value.data()!["id"].toString();
    Userr().nif = value.data()!["nif"].toString();
    Userr().postCode = value.data()!["postal_code"].toString();
    Userr().role = value.data()!["role"].toString();
  });
}

Future<bool> simpleConfirmationDialogue(
    {required BuildContext context,
      required String warning,
    }) async{
  return await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    warning,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).errorColor)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
          AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).errorColor)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
            ],
          );
        });
      }) ?? false;
}

Future<bool> showShoppingCart(BuildContext ctx) async{
  return await showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: ShoppingCart(),
          behavior: HitTestBehavior.opaque,
        );
      }) ?? true;
}

SnackBar newSnackBar(BuildContext context, Text content) {
  return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 6.0,
      content: content);
}

void showErrorDialog(BuildContext context, String title, Exception e) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                '${(e as dynamic).message}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          StyledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child:  Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            background: Colors.red,
            border: Colors.red,
          ),
        ],
      );
    },
  );
}
// Values derived from https://developer.apple.com/design/resources/ and on iOS
// simulators with "Debug View Hierarchy".
const double _kItemExtent = 32.0;
// From the picker's intrinsic content size constraint.
const double _kPickerWidth = 320.0;
const double _kPickerHeight = 216.0;
// The density of a date picker is different from a generic picker.
// Eyeballed from iOS.
const double _kSqueeze = 1.25;
// Considers setting the default background color from the theme, in the future.
const Color _kBackgroundColor = CupertinoColors.white;
// Half of the horizontal padding value between the timer picker's columns.
const double _kTimerPickerHalfColumnPadding = 2;
// The horizontal padding between the timer picker's number label and its
// corresponding unit label.
const double _kTimerPickerLabelPadSize = 4.5;
const double _kTimerPickerLabelFontSize = 17.0;

// The width of each colmn of the countdown time picker.
const double _kTimerPickerColumnIntrinsicWidth = 106;
// Unfortunately turning on magnification for the timer picker messes up the label
// alignment. So we'll have to hard code the font size and turn magnification off
// for now.
const double _kTimerPickerNumberLabelFontSize = 23;
// fix ###############
const TimeOfDay _startRestriction = TimeOfDay(hour: 0, minute: 0);
const TimeOfDay _endRestriction = TimeOfDay(hour: 23, minute: 59);
// ####################
class CustomCupertinoTimerPicker extends StatefulWidget {
  /// Constructs an iOS style countdown timer picker.
  ///
  /// [mode] is one of the modes listed in [CupertinoTimerPickerMode] and
  /// defaults to [CupertinoTimerPickerMode.hms].
  ///
  /// [onTimerDurationChanged] is the callback called when the selected duration
  /// changes and must not be null.
  ///
  /// [initialTimerDuration] defaults to 0 second and is limited from 0 second
  /// to 23 hours 59 minutes 59 seconds.
  ///
  /// [minuteInterval] is the granularity of the minute spinner. Must be a
  /// positive integer factor of 60.
  ///
  /// [secondInterval] is the granularity of the second spinner. Must be a
  /// positive integer factor of 60.
  // fix ###############
  final TimeOfDay startRestriction;
  final TimeOfDay endRestriction;
  // ####################
  CustomCupertinoTimerPicker({
    required Key key,
    this.mode = CupertinoTimerPickerMode.hms,
    this.initialTimerDuration = Duration.zero,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.alignment = Alignment.center,
    this.backgroundColor = _kBackgroundColor,
    // fix ###############
    this.startRestriction = _startRestriction,
    this.endRestriction = _endRestriction,
    // ####################
    required this.onTimerDurationChanged,
  }) : assert(mode != null),
        assert(onTimerDurationChanged != null),
        assert(initialTimerDuration >= Duration.zero),
        assert(initialTimerDuration < const Duration(days: 1)),
        assert(minuteInterval > 0 && 60 % minuteInterval == 0),
        assert(secondInterval > 0 && 60 % secondInterval == 0),
        assert(initialTimerDuration.inMinutes % minuteInterval == 0),
        assert(initialTimerDuration.inSeconds % secondInterval == 0),
        assert(backgroundColor != null),
        assert(alignment != null),
        super(key: key);

  /// The mode of the timer picker.
  final CupertinoTimerPickerMode mode;

  /// The initial duration of the countdown timer.
  final Duration initialTimerDuration;

  /// The granularity of the minute spinner. Must be a positive integer factor
  /// of 60.
  final int minuteInterval;

  /// The granularity of the second spinner. Must be a positive integer factor
  /// of 60.
  final int secondInterval;

  /// Callback called when the timer duration changes.
  final ValueChanged<Duration> onTimerDurationChanged;

  /// Defines how the timer picker should be positioned within its parent.
  ///
  /// This property must not be null. It defaults to [Alignment.center].
  final AlignmentGeometry alignment;

  /// Background color of timer picker.
  ///
  /// Defaults to [CupertinoColors.white] when null.
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _CustomCupertinoTimerPickerState();
}

class _CustomCupertinoTimerPickerState extends State<CustomCupertinoTimerPicker> {
  TextDirection? textDirection;
  CupertinoLocalizations? localizations;
  int get textDirectionFactor {
    switch (textDirection!) {
      case TextDirection.ltr:
        return 1;
      case TextDirection.rtl:
        return -1;
    }
    return 1;
  }

  // The currently selected values of the picker.
  int? selectedHour;
  int? selectedMinute;
  int? selectedSecond;

  // On iOS the selected values won't be reported until the scrolling fully stops.
  // The values below are the latest selected values when the picker comes to a full stop.
  int? lastSelectedHour;
  int? lastSelectedMinute;
  int? lastSelectedSecond;

  final TextPainter textPainter = TextPainter();
  final List<String> numbers = List<String>.generate(10, (int i) => '${9 - i}');
  double? numberLabelWidth;
  double? numberLabelHeight;
  double? numberLabelBaseline;
  // fix ###############
  int startRestrictionMinute = 0;
  int endRestrictionMinute = 60;
  // ####################
  @override
  void initState() {
    super.initState();
    selectedMinute = widget.initialTimerDuration.inMinutes % 60;

    if (widget.mode != CupertinoTimerPickerMode.ms) {
      selectedHour = widget.initialTimerDuration.inHours;
      _changeRestrictionMinute();
    }

    if (widget.mode != CupertinoTimerPickerMode.hm)
      selectedSecond = widget.initialTimerDuration.inSeconds % 60;

    PaintingBinding.instance!.systemFonts.addListener(_handleSystemFontsChange);
  }

  void _handleSystemFontsChange() {
    setState(() {
      // System fonts change might cause the text layout width to change.
      textPainter.markNeedsLayout();
      _measureLabelMetrics();
    });
  }

  void _changeRestrictionMinute() {
    setState(() {
      if(selectedHour == widget.endRestriction.hour) {
        endRestrictionMinute = widget.endRestriction.minute;
      } else {
        endRestrictionMinute = 60;
      }
      if(selectedHour == widget.startRestriction.hour) {
        startRestrictionMinute = widget.startRestriction.minute;
      } else {
        startRestrictionMinute = 0;
      }
    });
  }

  @override
  void dispose() {
    PaintingBinding.instance!.systemFonts.removeListener(_handleSystemFontsChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomCupertinoTimerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
    oldWidget.mode == widget.mode,
    "The CupertinoTimerPicker's mode cannot change once it's built",
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    textDirection = Directionality.of(context);
    localizations = CupertinoLocalizations.of(context);

    _measureLabelMetrics();
  }

  void _measureLabelMetrics() {
    textPainter.textDirection = textDirection;
    final TextStyle textStyle = _textStyleFrom(context);

    double maxWidth = double.negativeInfinity;
    String? widestNumber;

    // Assumes that:
    // - 2-digit numbers are always wider than 1-digit numbers.
    // - There's at least one number in 1-9 that's wider than or equal to 0.
    // - The widest 2-digit number is composed of 2 same 1-digit numbers
    //   that has the biggest width.
    // - If two different 1-digit numbers are of the same width, their corresponding
    //   2 digit numbers are of the same width.
    for (String input in numbers) {
      textPainter.text = TextSpan(
        text: input,
        style: textStyle,
      );
      textPainter.layout();

      if (textPainter.maxIntrinsicWidth > maxWidth) {
        maxWidth = textPainter.maxIntrinsicWidth;
        widestNumber = input;
      }
    }

    textPainter.text = TextSpan(
      text: '$widestNumber$widestNumber',
      style: textStyle,
    );

    textPainter.layout();
    numberLabelWidth = textPainter.maxIntrinsicWidth;
    numberLabelHeight = textPainter.height;
    numberLabelBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }

  // Builds a text label with scale factor 1.0 and font weight semi-bold.
  // `pickerPadding ` is the additional padding the corresponding picker has to apply
  // around the `Text`, in order to extend its separators towards the closest
  // horizontal edge of the encompassing widget.
  Widget _buildLabel(String text, EdgeInsetsDirectional pickerPadding) {
    final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
      start: numberLabelWidth!
          + _kTimerPickerLabelPadSize
          + pickerPadding.start,
    );

    return IgnorePointer(
      child: Container(
        alignment: AlignmentDirectional.centerStart.resolve(textDirection),
        padding: padding.resolve(textDirection),
        child: SizedBox(
          height: numberLabelHeight,
          child: Baseline(
            baseline: numberLabelBaseline!,
            baselineType: TextBaseline.alphabetic,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: _kTimerPickerLabelFontSize,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }

  // The picker has to be wider than its content, since the separators
  // are part of the picker.
  Widget _buildPickerNumberLabel(String text, EdgeInsetsDirectional padding) {
    return Container(
      width: _kTimerPickerColumnIntrinsicWidth + padding.horizontal,
      padding: padding.resolve(textDirection),
      alignment: AlignmentDirectional.centerStart.resolve(textDirection),
      child: Container(
        width: numberLabelWidth,
        alignment: AlignmentDirectional.centerEnd.resolve(textDirection),
        child: Text(text, softWrap: false, maxLines: 1, overflow: TextOverflow.visible),
      ),
    );
  }
// fix ###############
  Widget _buildHourPicker(EdgeInsetsDirectional additionalPadding) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
          initialItem: selectedHour! - widget.startRestriction.hour
      ),
      offAxisFraction: -0.5 * textDirectionFactor,
      itemExtent: _kItemExtent,
      backgroundColor: widget.backgroundColor,
      squeeze: _kSqueeze,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedHour = widget.startRestriction.hour + index;
          _changeRestrictionMinute();
          widget.onTimerDurationChanged(
              Duration(
                  hours: selectedHour ?? 0,
                  minutes: selectedMinute!,
                  seconds: selectedSecond ?? 0));
        });
      },
      children: _generateHourList(additionalPadding),
    );
  }

  List<Widget> _generateHourList(
      EdgeInsetsDirectional additionalPadding
      ){
    List<Widget> widgets = [];
    int startHour = widget.startRestriction.hour;
    int endHour = widget.endRestriction.hour;

    for (var index = startHour; index <= endHour; index++) {
      final String semanticsLabel = textDirectionFactor == 1
          ? localizations!.timerPickerHour(index) + localizations!.timerPickerHourLabel(index)!
          : localizations!.timerPickerHourLabel(index)! + localizations!.timerPickerHour(index);
      widgets.add(
          Semantics(
            label: semanticsLabel,
            excludeSemantics: true,
            child: _buildPickerNumberLabel(localizations!.timerPickerHour(index), additionalPadding),
          )
      );
    }
    return widgets;
  }
// ####################

  Widget _buildHourColumn(EdgeInsetsDirectional additionalPadding) {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() { lastSelectedHour = selectedHour; });
            return false;
          },
          child: _buildHourPicker(additionalPadding),
        ),
        _buildLabel(
          localizations!.timerPickerHourLabel(lastSelectedHour ?? selectedHour!)!,
          additionalPadding,
        ),
      ],
    );
  }
// fix ###############
  Widget _buildMinutePicker(EdgeInsetsDirectional additionalPadding) {
    double offAxisFraction;
    switch (widget.mode) {
      case CupertinoTimerPickerMode.hm:
        offAxisFraction = 0.5 * textDirectionFactor;
        break;
      case CupertinoTimerPickerMode.hms:
        offAxisFraction = 0.0;
        break;
      case CupertinoTimerPickerMode.ms:
        offAxisFraction = -0.5 * textDirectionFactor;
    }

    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: selectedMinute! ~/ widget.minuteInterval,
      ),
      offAxisFraction: offAxisFraction,
      itemExtent: _kItemExtent,
      backgroundColor: widget.backgroundColor,
      squeeze: _kSqueeze,
      looping: true,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedMinute = index * widget.minuteInterval + startRestrictionMinute;
          widget.onTimerDurationChanged(
              Duration(
                  hours: selectedHour ?? 0,
                  minutes: selectedMinute!,
                  seconds: selectedSecond ?? 0));
        });
      },
      children: _generateMinuteList(additionalPadding),
    );
  }

  List<Widget> _generateMinuteList(
      EdgeInsetsDirectional additionalPadding
      ){
    List<Widget> widgets = [];
    int iterations = (endRestrictionMinute - startRestrictionMinute) ~/ widget.minuteInterval;
    if(endRestrictionMinute < 60) iterations = iterations + 1;
    for (var index = 0; index < iterations; index++) {
      final int minute = index * widget.minuteInterval + startRestrictionMinute;
      final String semanticsLabel = textDirectionFactor == 1
          ? localizations!.timerPickerMinute(minute) + localizations!.timerPickerMinuteLabel(minute)!
          : localizations!.timerPickerMinuteLabel(minute)! + localizations!.timerPickerMinute(minute);

      widgets.add(
          Semantics(
            label: semanticsLabel,
            excludeSemantics: true,
            child: _buildPickerNumberLabel(localizations!.timerPickerMinute(minute), additionalPadding),
          )
      );

    }

    return widgets;
  }
// ####################
  Widget _buildMinuteColumn(EdgeInsetsDirectional additionalPadding) {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() { lastSelectedMinute = selectedMinute; });
            return false;
          },
          child: _buildMinutePicker(additionalPadding),
        ),
        _buildLabel(
          localizations!.timerPickerMinuteLabel(lastSelectedMinute ?? selectedMinute!)!,
          additionalPadding,
        ),
      ],
    );
  }

  Widget _buildSecondPicker(EdgeInsetsDirectional additionalPadding) {
    final double offAxisFraction = 0.5 * textDirectionFactor;

    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: selectedSecond! ~/ widget.secondInterval,
      ),
      offAxisFraction: offAxisFraction,
      itemExtent: _kItemExtent,
      backgroundColor: widget.backgroundColor,
      squeeze: _kSqueeze,
      looping: true,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedSecond = index * widget.secondInterval;
          widget.onTimerDurationChanged(
              Duration(
                  hours: selectedHour ?? 0,
                  minutes: selectedMinute!,
                  seconds: selectedSecond!));
        });
      },
      children: List<Widget>.generate(60 ~/ widget.secondInterval, (int index) {
        final int second = index * widget.secondInterval;

        final String semanticsLabel = textDirectionFactor == 1
            ? localizations!.timerPickerSecond(second) + localizations!.timerPickerSecondLabel(second)!
            : localizations!.timerPickerSecondLabel(second)! + localizations!.timerPickerSecond(second);

        return Semantics(
          label: semanticsLabel,
          excludeSemantics: true,
          child: _buildPickerNumberLabel(localizations!.timerPickerSecond(second), additionalPadding),
        );
      }),
    );
  }

  Widget _buildSecondColumn(EdgeInsetsDirectional additionalPadding) {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() { lastSelectedSecond = selectedSecond; });
            return false;
          },
          child: _buildSecondPicker(additionalPadding),
        ),
        _buildLabel(
          localizations!.timerPickerSecondLabel(lastSelectedSecond ?? selectedSecond!)!,
          additionalPadding,
        ),
      ],
    );
  }

  TextStyle _textStyleFrom(BuildContext context) {
    return CupertinoTheme.of(context).textTheme
        .pickerTextStyle.merge(
      const TextStyle(
        fontSize: _kTimerPickerNumberLabelFontSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The timer picker can be divided into columns corresponding to hour,
    // minute, and second. Each column consists of a scrollable and a fixed
    // label on top of it.

    List<Widget> columns;
    const double paddingValue = _kPickerWidth - 2 * _kTimerPickerColumnIntrinsicWidth - 2 * _kTimerPickerHalfColumnPadding;
    // The default totalWidth for 2-column modes.
    double totalWidth = _kPickerWidth;
    assert(paddingValue >= 0);

    switch (widget.mode) {
      case CupertinoTimerPickerMode.hm:
      // Pad the widget to make it as wide as `_kPickerWidth`.
        columns = <Widget>[
          _buildHourColumn(const EdgeInsetsDirectional.only(start: paddingValue / 2, end: _kTimerPickerHalfColumnPadding)),
          _buildMinuteColumn(const EdgeInsetsDirectional.only(start: _kTimerPickerHalfColumnPadding, end: paddingValue / 2)),
        ];
        break;
      case CupertinoTimerPickerMode.ms:
      // Pad the widget to make it as wide as `_kPickerWidth`.
        columns = <Widget>[
          _buildMinuteColumn(const EdgeInsetsDirectional.only(start: paddingValue / 2, end: _kTimerPickerHalfColumnPadding)),
          _buildSecondColumn(const EdgeInsetsDirectional.only(start: _kTimerPickerHalfColumnPadding, end: paddingValue / 2)),
        ];
        break;
      case CupertinoTimerPickerMode.hms:
        const double paddingValue = _kTimerPickerHalfColumnPadding * 2;
        totalWidth = _kTimerPickerColumnIntrinsicWidth * 3 + 4 * _kTimerPickerHalfColumnPadding + paddingValue;
        columns = <Widget>[
          _buildHourColumn(const EdgeInsetsDirectional.only(start: paddingValue / 2, end: _kTimerPickerHalfColumnPadding)),
          _buildMinuteColumn(const EdgeInsetsDirectional.only(start: _kTimerPickerHalfColumnPadding, end: _kTimerPickerHalfColumnPadding)),
          _buildSecondColumn(const EdgeInsetsDirectional.only(start: _kTimerPickerHalfColumnPadding, end: paddingValue / 2)),
        ];
        break;
    }
    final CupertinoThemeData themeData = CupertinoTheme.of(context);
    return MediaQuery(
      data: const MediaQueryData(
        // The native iOS picker's text scaling is fixed, so we will also fix it
        // as well in our picker.
        textScaleFactor: 1.0,
      ),
      child: CupertinoTheme(
        data: themeData.copyWith(
          textTheme: themeData.textTheme.copyWith(
            pickerTextStyle: _textStyleFrom(context),
          ),
        ),
        child: Align(
          alignment: widget.alignment,
          child: Container(
            color: _kBackgroundColor,
            width: totalWidth,
            height: _kPickerHeight,
            child: DefaultTextStyle(
              style: _textStyleFrom(context),
              child: Row(children: columns.map((Widget child) => Expanded(child: child)).toList(growable: false)),
            ),
          ),
        ),
      ),
    );
  }
}
