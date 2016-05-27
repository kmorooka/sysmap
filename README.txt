■sysmapプログラム

2016.5.26　ver0.1


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


以上


