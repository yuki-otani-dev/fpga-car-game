# FPGA Car Avoidance Game

## Overview

高専在学中に開発した障害物回避ゲームです。

LEGOマインドストームに搭載したジャイロセンサの傾き情報をBluetoothでPCへ送信し、Processing上のゲーム画面に反映させました。また、受信した操作情報をFPGAへ送信し、7セグメントLEDに走行方向を表示しました。

## Features
- ジャイロセンサによる直観的な車両操作
- Bluetooth通信を用いたことによるケーブルレスな操作
- Processingを用いたゲーム画面
- FPGAによる7セグメントLEDのダイナミック点灯

## Technologies
- Processing (Java)
- Verilog HDL
- FPGA

## Demo
動作の様子はvideo/demo.mp4を参照してください。

## Documentation
システム構成や詳細についてはdocument/project_reportを参照してください。

## Source code
各ソースコードはsource codeフォルダ内のファイルを参照してください。
