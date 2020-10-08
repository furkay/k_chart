import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show MainState;
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  static Color lineColorC = ChartColors.kLineColor;
  static Color lineFillColorC = ChartColors.lineFillColor;
  static const chartGradientValue = <double>[0.0, 0.2, 0.4, 0.8, 1.0, 0.1];
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  MainState state;
  final Color lineColor;
  final Color lineFillColor;
  final double lineWidth;
  bool isLine;
  Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;
  Paint mLinePaint, mLineFillPaint;
  Shader mLineFillShader;
  Path mLinePath, mLineFillPath;
  MainRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding, this.state, this.isLine, int fixedLength,
      {this.maDayList = const [5, 10, 20],
      this.lineColor,
      this.lineFillColor,
      this.lineWidth = 1.0})
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            fixedLength: fixedLength) {
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
    lineColorC = lineColor;
    lineFillColorC = lineFillColor;
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..color = lineColorC ?? ChartColors.kLineColor;
    mLineFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up, curPoint.up, canvas, lastX, curX,
          ChartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(
          lastPoint.mb, curPoint.mb, canvas, lastX, curX, ChartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn, curPoint.dn, canvas, lastX, curX,
          ChartColors.ma30Color);
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open > close) {
      chartPaint.color = ChartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else if (close > open) {
      chartPaint.color = ChartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else {
      chartPaint.color = ChartColors.upColor;
      canvas.drawLine(
          Offset(curX - r, open), Offset(curX + r, open), chartPaint);
      if (high != low) {
        canvas.drawRect(
            Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
      }
    }
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (isLine != true) {
      drawCandle(curPoint, canvas, curX);
    }
    if (isLine == true) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else if (state == MainState.MA) {
      drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
    } else if (state == MainState.BOLL) {
      drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    for (int i = 0; i < curPoint.maValueList.length; i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList[i] != 0) {
        drawLine(lastPoint.maValueList[i], curPoint.maValueList[i], canvas,
            lastX, curX, ChartColors.getMAColor(i));
      }
    }
  }

  drawPolyline(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
    mLinePath ??= Path();

    if (lastX == curX) lastX = 0;
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

    mLineFillShader ??= LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: chartGradientValue
                .map(
                  (f) => lineFillColorC.withAlpha(
                    (255 * f).toInt(),
                  ),
                )
                .toList(),
            stops: chartGradientValue)
        .createShader(Rect.fromLTRB(
            chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();
    canvas.drawPath(mLinePath, mLinePaint);
    mLinePath.reset();
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas, Offset(chartRect.width - tp.width, topPadding));
      } else {
        tp.paint(
            canvas,
            Offset(chartRect.width - tp.width,
                rowSpace * i - tp.height + topPadding));
      }
    }
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan span;
    if (state == MainState.MA) {
      span = TextSpan(
        children: _createMATextSpan(data),
      );
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          if (data.up != 0)
            TextSpan(
                text: "BOLL:${format(data.mb)}    ",
                style: getTextStyle(ChartColors.ma5Color)),
          if (data.mb != 0)
            TextSpan(
                text: "UB:${format(data.up)}    ",
                style: getTextStyle(ChartColors.ma10Color)),
          if (data.dn != 0)
            TextSpan(
                text: "LB:${format(data.dn)}    ",
                style: getTextStyle(ChartColors.ma30Color)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  double getY(double y) {
    return (maxValue - y) * scaleY + _contentRect.top;
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < data.maValueList.length; i++) {
      if (data.maValueList[i] != 0) {
        var item = TextSpan(
            text: "MA${maDayList[i]}:${format(data.maValueList[i])}    ",
            style: getTextStyle(ChartColors.getMAColor(i)));
        result.add(item);
      }
    }
    return result;
  }
}
