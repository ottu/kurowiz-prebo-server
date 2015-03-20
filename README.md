# これは？
「魔法使いの黒猫とウィズ」にて実装は不可能と表明されてしまった  
プレゼントボックスのソート機能をどうにかしようと頑張るやつ。  
でもプレボの中身は全部手動管理。

## 使い方
まず news.csv にプレボのカードをひたすら写経していく。  
この時プレボの順番を守る事。  

写経が終わったら`./kurowiz-sort generate`を実行する。  
list.json が更新されます。  
直前の list.jsonは backup.jsonとリネームされてますので  
何やら失敗した時には置き換えて復旧してください。

カードをプレボから出した場合は、  
list.json から該当の cardオブジェクトを削除する。  
この時ページに歯抜けが出来ますが、そこは generateし直せば勝手に詰めてくれます。

カードがプレボに追加された場合は、  
news.csv に都度追加していく。


**list.json**

これがプレボの代わりになる json。

* pages キー
  * page オブジェクトの配列
* page オブジェクト
  * page キー
    * このオブジェクトが何ページ目に当たるか
  * cards キー
    * card オブジェクトの配列  
    最大 10個まで cardオブジェクトを含む
* card オブジェクト
  * name
    * 名前
  * element キー
    * 属性 ( fire or water or thunder or none )
  * category キー
    * カテゴリ ( spirit or material or mana or ether or mate or crystal or gold )
  * rank
    * レア度 ( C+ or B or B+ or A+ or S or SS or SS+ or L or 任意 )
  * option
    * オプション  
    エーテルの確率とかマナの加算数とか何ゴールドかとか任意の文字列突っ込めます。
  
**news.csv**

名前,属性,カテゴリ,ランク,オプション の 5項目を , で区切って書く。  
このファイルの先頭から順に  
プレボの 1ページ 1枚目... 2枚目... と追加されてく。

## カードの絞り込み

### 例1: 素材全部
`./kurowiz-sort search --category material`

### 例2: 火の素材全部
`./kurowiz-sort search --element fire --category material`

### 例3: マナ、エーテルを全部
`./kurowiz-sort search --category mana --category ether`

### 例4: 名前検索 (部分一致)
`./kurowiz-sort search --name "猫"`

### 例5: 名前検索 (正規表現)
`./kurowiz-sort search --name "^星くじらの奏姫 キシャラ・オロル$"`

## カードのソート

未実装。
今の所 list.jsonに沿った順番でしか絞り込み結果を表示できない。
