## このプルリクエストは何なのか？

## どうやってテストすればいいのか？

## どうやって実装したのか？

## スクリーンショット

## 質問事項

## Merge前のチェック事項（全てパスしなければMergeはしないこと）

- [ ] CircleCIを通すこと
* CirclrCIをFixedまたはSuccessの状態にしておくこと。

- [ ] SiderCIを通すこと
* SiderCIをFixedまたはSuccessの状態にしておくこと。
* もし不要なチェックがある場合はCloseすること。

- [ ] 動作確認を通すこと。
* セルフで動作確認をパスした後に、自分以外に動作確認を依頼してパスすること。
* 依頼するときは、pullrequestのbodyにテスト方法を書くこと。

- [ ] Mergeした後は、、、
* Mergeをした後は、stg環境で動作確認をすること。
* またstg上の動作確認も自分以外の人にも依頼すること。

* 万が一バグを見つけた時は、issueを起票すること。
