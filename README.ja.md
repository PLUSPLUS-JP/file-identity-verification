# ファイルデータのハッシュ値をブロックチェーンで管理する実装

*Read this in other languages: [English](README.en.md), [日本語](README.ja.md).*

## 概要

スマートコントラクトを使ってファイルのデータのハッシュ値をブロックチェーンで管理し、そのファイルが確実にある時点で存在していたことを確認できる仕組みを実装する

## 要点

- ファイルの情報のハッシュ値３種類（MD5 SHA-2(SHA256/SHA512)）を生成し、ブロックチェーンで登録する。
- ハッシュ値計算はブロックチェーンの外で行う。
- ブロックチェーンにはファイルを特定できる情報は登録しない。登録した情報は消去することはできない。

## ブロックチェーンで管理する情報

- ファイルの情報のハッシュ値３種類（MD5 SHA-2(SHA256/SHA512)）
- ３種類のハッシュ値を組み合わせて生成したファイルID
- 登録したユーザーのETHアドレス
- 情報がブロックチェーンに取り込まれたときのタイムスタンプ

## このDappsによって実現できること

ファイルの情報が記録されるため、記録の改ざんなどの心配がない

## 課題

- ファイルの登録者がGASを支払う必要がある
- 登録したファイルがこの先も存在するのか？は管理できない（管理しない）

## 仕様

### ファイルIDの計算

*引数*

- string `_md5` : MD5ハッシュ値
- string `_sha256` : SHA256ハッシュ値
- string `_sha512` : SHA512ハッシュ値

*戻り値*

- byte32 : 計算したファイルID

```solidity
return keccak256(abi.encodePacked(bytes(_md5), bytes(_sha256), bytes(_sha512)));
```

*関数*

```solidity
function getFileId(string memory _md5, string memory _sha256, string memory _sha512) public pure returns (bytes32);
```

### ファイルの登録

*引数*

- string `_md5` : MD5ハッシュ値
- string `_sha256` : SHA256ハッシュ値
- string `_sha512` : SHA512ハッシュ値

*関数*

```solidity
function registerFileHash(string memory _md5, string memory _sha256, string memory _sha512);
```

![ファイルの登録](./sequence-diagram/register-file-hash.svg)

### ファイルの抹消

抹消処理は実装しない

### ファイルが登録済みか？

ファイルIDは前述の「ファイルIDの計算」で取得する。

*引数*

- string `fileId` : ファイルID

*戻り値*

- bool : true:登録済み false:未登録


*関数*

```solidity
function isExist(bytes32 fileId) public view returns (bool);
```

![ファイルの検証](./sequence-diagram/get-file-identity.svg?)

### ファイル情報を照会

ファイルIDは前述の「ファイルIDの計算」で取得する。

*引数*

- string `fileId` : ファイルID

*戻り値*

- bytes32 `_fileId` ファイルID
- bytes `_md5` : MD5ハッシュ値
- bytes `_sha256` : SHA256ハッシュ値
- bytes `_sha512` : SHA512ハッシュ値
- address `_registrant` : 登録者EOA
- uint _`timestamp` : 取り込まれたブロックのタイムスタンプ
- uint `_isExist` : 登録済みの場合は常に `1`

*関数*

```solidity
function getFileIdentity(bytes32 fileId) public view
returns (bytes32 _fileId, bytes memory _md5, bytes memory _sha256, bytes memory _sha512, address _registrant, uint _timestamp, uint _isExist)
```


## 実装

実装はGitHubにて公開する。

https://github.com/PLUSPLUS-JP/file-identity-verification
