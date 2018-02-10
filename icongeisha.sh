#!/bin/sh

function usage {
cat <<_EOT_
$(basename ${0}) は iOS 開発時に必要な各サイズのアイコンファイルと定義ファイルを生成します。

Usage:
    $(basename ${0}) [original image]

    引数は画像ファイル名となります。一辺が1024ピクセル以上の正方形の画像を
    用意してください。
    実行時のフォルダ下に AppIcon.appiconset というフォルダが作成され、
    必要なファイル一式が作成されます。フォルダはそのままプロジェクト内の
    同名フォルダに置き換えて使うことを意図した構成になっています。
    (Xcode 9.2 で確認)

Options:
    -h  print this
    -v  print $(basename ${0}) version
_EOT_
    exit 1
}

function version {
cat <<_EOT_
$(basename ${0}) version 0.0.1
_EOT_
    exit 1
}

# option
while getopts hv OPT
do
  case $OPT in
      v ) version ;;
      h ) usage ;;
      \?) usage ;;
  esac
done

# オリジナル画像名（引数省略時）
sourcefile="icon_1024x1024.png"
# 引数がある場合
if [ $# -eq 1 ]; then
    sourcefile=$1
fi

# オリジナル画像の確認

# ファイルの存在チェック
if [ ! -e ${sourcefile} ]; then
    echo "error : ${sourcefile} が見つかりませんでした。"
    exit
fi

# 画像サイズのチェック
workstr=$(sips -g pixelWidth ${sourcefile} -g pixelHeight)
param=(`echo ${workstr}`)
pixelW=${param[2]}
pixelH=${param[4]}

# 正方形でかつ1024ピクセル以上を条件とする。
if [ ${pixelH} != ${pixelW} ] || [ ${pixelW} -lt 1024 ]; then
    echo "error : 一辺が 1024 ピクセル以上の正方形の画像を用意してください。"
    exit
fi

# アイコン生成パラメータ
#   形式 : "[目的] [サイズ] [倍率]"
#   用途 : アイコンの用途。iphone, ipad, ios-marketing のいずれかを使用 (2018.02 現在)。
#   サイズ : 倍率適用前の一辺の長さ。
#   倍率 : 高解像度ディスプレイのための倍率 1, 2, 3 のいずれかを使用 (2018.02 現在)。
# 実際の画像ピクセル数はサイズ * 倍率となる。ファイル名もこれらのパラメータから決められる。

testcases=( 
    "iphone 20 2"
    "iphone 20 3"
    "iphone 29 2"
    "iphone 29 3"
    "iphone 40 2"
    "iphone 40 3"
    "iphone 60 2"
    "iphone 60 3"
    "ipad 20 1"
    "ipad 20 2"
    "ipad 29 1"
    "ipad 29 2"
    "ipad 40 1"
    "ipad 40 2"
    "ipad 76 1"
    "ipad 76 2"
    "ipad 83.5 2"
    "ios-marketing 1024 1"
)

# 出力先のフォルダ
exportdir="AppIcon.appiconset"
mkdir -p $exportdir

# Contents.json に保存する文字列
contents="{\n  \"images\" : [\n"

counter=0
for param in "${testcases[@]}"
do
    let counter++
    testcase=(`echo ${param}`)
    idiom=${testcase[0]}
    base_size=${testcase[1]}
    scale=${testcase[2]}
    # 小数の場合があるので expr は使わない
    size=`echo "${base_size} * ${scale}" | bc`

    # ファイル名を決定
    if [ ${idiom} == "ios-marketing" ]; then
        filename="ItunesArtwork@${scale}x.png"
    else
        filename="Icon-${idiom}-${base_size}x${base_size}@${scale}x.png"
    fi

    # サイズ変更したアイコンファイルを作成し、存在チェックを行わずに上書き。
    sips -Z ${size} --out ${exportdir}/${filename} ${sourcefile}

    # Contents に一件追記
    contents+="    {\n"
    contents+="      \"size\" : \"${base_size}x${base_size}\",\n"
    contents+="      \"idiom\" : \"${idiom}\",\n"
    contents+="      \"filename\" : \"${filename}\",\n"
    contents+="      \"scale\" : \"${scale}x\"\n    }"
    [ "$counter" != ${#testcases[@]} ] && contents+=","
    contents+="\n"
done

contents+="  ],\n  \"info\" : {\n    \"version\" : 1,\n    \"author\" : \"xcode\"\n  }\n}"

# Contents データを json ファイルに保存
echo "${contents}" > "${exportdir}/Contents.json"
