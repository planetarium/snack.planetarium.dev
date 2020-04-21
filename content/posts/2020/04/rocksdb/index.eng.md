---
title: Applying RocksDB to Libplanet
date: 2020-04-17
authors: [seunghun.lee]
translators: [kidon.seo]
---

Hello, I'm Seunghun Lee, [Libplanet] developer at Planetarium.

Libplanet provides a storage layer abstraction interface called [`IStore`] and its basic implementation called [`DefaultStore`]. `DefaultStore` had been used to develop [Nine Chronicles] and although it was included as a base in Libplanet and had the upside of being able to use it immediately, there were certainly limitations in terms of performance and storage efficiency.

After reviewing various alternative storage methods, we decided that [RocksDB], a [Key-Value Database] library developed by Facebook, was our best option. We decided to create an `IStore` implementation called [`RocksDBStore`] to use as a backend. In this article, I would like to share our experiences in developing `RocksDBStore`.


[Libplanet]: https://libplanet.io/
[`IStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.IStore.html
[`DefaultStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.DefaultStore.html
[RocksDB]: https://rocksdb.org/
[Nine Chronicles]: https://nine-chronicles.com/
[Key-Value Database]: https://en.wikipedia.org/wiki/Key-value_database
[`RocksDBStore`]: https://github.com/planetarium/libplanet/blob/master/Libplanet.RocksDBStore/RocksDBStore.cs

## Including Dependent Libraries[^1]

RocksDB relies on other libraries for compression or memory allocation purposes. Unlike [Windows build], for macOS and Linux, the dependent libraries must also be installed in the system to use the RocksDB native library in the form of a dynamic link library (*.so* and .*dylib*).

In a typical server app, it is natural to install all dependent libraries in your system. This is because the system that runs the server app is usually operated only for that server app. But because we're building an app that serves as blockchain nodes and runs on gamers' systems, it's hard to ask all gamers to install these libraries separately.

So what we came up with was to put the libraries that RocksDB relies on in the game client and distribute them. However, building RocksDB in the form of a dynamic link library without any modifications caused the built RocksDB library to not be able to find the dependent libraries that were included in the game clients.

To resolve this issue, we used a method of modifying [rpath] in the RocksDB dynamic link library file. rpath refers to <q>run-time search path</q>, which is hard-coded within a library file or executable file so the [dynamic linking] [loader] can find the required library in that file. Initially, we considered modifying the rpath when building the RocksDB library, but we eventually decided to modify the rpath in the completed library file because the build script in RocksDB turned out to be more complicated than we thought. Fortunately, with tools called [`install_name_tool`] on macOS and [`patchelf`] on Linux, you can simply modify the rpath to the directory where the current RocksDB library exists.


```
# macOS
$ install_name_tool -add-rpath '@loader_path' librocksdb.dylib

# linux
$ patchelf --set-rpath $ORIGIN librocksdb.so
```

For more information on rpath modification, please refer to the pages below:


- [Fun with rpath, otool, and install\_name\_tool](https://medium.com/@donblas/fun-with-rpath-otool-and-install-name-tool-e3e41ae86172)
- [Change Library Search Path For Binary Files in Linux](https://mindonmind.github.io/notes/linux/change_rpath.html)


[Windows Build]: https://github.com/facebook/rocksdb/wiki/Building-on-Windows
[rpath]: https://en.wikipedia.org/wiki/Rpath
[dynamic linking]: https://en.wikipedia.org/wiki/Dynamic_linker
[loader]: https://en.wikipedia.org/wiki/Loader_(computing)
[`install_name_tool`]: https://www.unix.com/man-page/osx/1/install_name_tool/
[`patchelf`]: https://github.com/NixOS/patchelf
[^1]: We took this approach during this phase because Nine Chronicles was being tested to only a small number of players, enabling us to distribute files without an installer. However, now that we’re deploying Nine Chronicles with an installer, other approaches have been developed. We will introduce some of them on Snack in the near future.

## Implementing Database Capabilities in Applications

RocksDB supports relatively simple functionality, unlike the common [relational database] or [LiteDB] used in `DefaultStore`. Therefore, commonly supported features are often required to be directly implemented by the application when using RocksDB.

For instance, since there is no method to count the number of rows of stored data, it is necessary to implement them using various ways, such as storing the number separately every time data is updated or counting while traversing the entire data on each update.

Another example is the key search feature. RocksDB's `Seek` takes the prefix of the key as input to locate the key. While it's easy to assume that this feature will only find keys that match the prefix like a typical database search, it's actually more similar to [`lseek()`][lseek(2)], which moves the offset of the file. Therefore, when using this feature to traverse a key, you need to check at each key that the first head of that key matches the string parts you are looking for.

[relational database]: https://en.wikipedia.org/wiki/Relational_database
[LiteDB]: https://www.litedb.org/
[lseek(2)]: http://man7.org/linux/man-pages/man2/lseek.2.html

## Common Mistakes when Overlooking the Docs

The APIs and documentation of RocksDB were not as user-friendly as expected, so extra attention was needed to use it.

One example was the [Column Family], which acts like a namespace. After creating a column family in the database, we expected the column family to be brought up automatically when using the database again. However, an exception occurs if we did not specify all column families in the database using the API called `ListColumnFamilies` when opening the database.

Also, although RocksDB uses GitHub Wiki for documentation, there is no separate arrangement such as documents divided by version. For example, if you look at the document for [prefix seek], the most recent usage is written at the end of the document, making it easy to use the outdated one if you only read the first part of the document.

[Column Family]: https://github.com/facebook/rocksdb/wiki/Column-Families
[prefix seek]: https://github.com/facebook/rocksdb/wiki/Prefix-Seek

## Problems with Binding Libraries

Finally, let’s talk about [rocksdb-sharp], a C# binding library of RocksDB.

Among `RocksDBStore` codes, one code handles `RocksDBException` of rocksdb-sharp. But on some platforms, we experienced the following unusual issue while handling this exception.

    ExecutionEngineException: String conversion error: Illegal byte sequence encounted in the input.

After looking at the code, we figured out that this was caused by rocksdb-sharp using the [`Marshal.PtrToStringAnsi()`] method when encoding an error message generated by RocksDB. Since we were forking rocksdb-sharp to solve the library dependency problem discussed above, we were able to solve the problem without much difficulty by changing the particular method to [`Marshal.PtrToStringUni()`].


[rocksdb-sharp]: https://github.com/warrenfalk/rocksdb-sharp
[`Marshal.PtrToStringAnsi()`]: https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshal.ptrtostringansi?view=netframework-4.8
[`Marshal.PtrToStringUni()`]: https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshal.ptrtostringuni?view=netframework-4.8

## Closing

Through many different processes, we have applied RocksDB and experienced improvements in storage space and speed. Please refer to our [code][`RocksDBStore`] for detailed implementation.

And as always, if you have any questions about RocksDBStore or Libplanet in general, please visit our [Discord] and let’s chat!


[Discord]: https://discord.gg/planetarium
