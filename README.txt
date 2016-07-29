■sysmapプログラム

2016.5.26　ver0.1

▼注意事項
１．エラー処理等は一切していません。ノーマルパスだけです。
２．ライブラリーがプリミティブでワークを掛けたくなかったので見た目が貧弱です。
３．入力形式に整える事前作業の方に時間がかかると想定されます。

▼インストール

(1)Pythonの導入
		
PyCall＠Githubの推奨に従って、AnacondaのPython(64bit-v2.7)を導入（https://www.continuum.io/downloads）

(2)Python PPTXライブラリーの導入

pipでやるとエラーになるので、手動で下記を実施
python-pptxのサイトからダウンロードし、tar.gzを解凍
Dosコマンドプロンプトから下記実行
　　python setup.py install

(3)Juliaの導入

Juliaのサイトからダウンロード
Juliaを導入
Windowsでパスに、Julia\binを追加
julia\Git\git-cmd.exe を実行（一時的にPathへGitを追加するだけ？）

(4)sysmapプログラムの導入

ファイル一式を何処かのディレクトリに配置
このディレクトリは、Julia、Pythonともにパスが通っていること。

(5)sysmapの実行

Dosコマンドプロンプトから下記コマンドを実行

> python sysmap.py <SJISデータファル名> <出力パワポファイル名>　[CR]

例えば、python sysmap.py testdata.csv sysmap.pptx [CR]

▼仕様
・sysmap.pyからsysmap_jl.jlを呼び出し、その中でcsvデータを読み込んで依存関係を基に、pptx上の座標位置を計算し、中間一時ファイルに座標情報を書き出す。
・sysmap_pptx.pyが、座標情報の書かれた一時ファイルを読み込んでpptxライブラリーによってスライドに描画。終了後、中間一時ファイルを削除

・sysmap.pyでは、入力されるcsvまたはtxtファイルはSJISを想定し、プログラム中でUTF8へ変換している。（JuliaがUTF8であるため、Juliaで処理するデータを予めUTF8へ要変換）
・csv形式のデータファイルは、実際には下記のカラムだけについてプログラムから参照していない。
　appl、PV、appl_server、pOS、Clustering、pMiddle、Hypervisor、VM、vOS、vMiddle
・上記カラムは列位置をハードコードしているため、列順序が変更されるとNG
・python-pptxライブラリーを前提としている。
・pptxライブラリーでは、座標位置をJuliaで計算している。
・pptxスライドのサイズは、４：３、１６：９の２種類があるが、１６：９でハードコード
・位置決めは、左上から右横方向がLeft、下に向かってTop、表示オブジェクトの幅はwidth、高さはheightで指定する。
・Leftは10mmをハードコード
・TopはオブジェクトをLevel１～８までとし、上から下に向かってL8～L1の位置をハードコードしている。


以上


