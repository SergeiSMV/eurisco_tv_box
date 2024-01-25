import 'package:eurisco_tv_box/data/implements/server_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors.dart';
import '../data/implements/device_implementation.dart';
import '../data/providers.dart';
import 'auth.dart';
import 'content_lib.dart';

Widget appBar(BuildContext mainContext, Map deviceConfig){
  
  return ProviderScope(
    parent: ProviderScope.containerOf(mainContext),
    child: Consumer(
      builder: (context, ref, child){
        final containerSize = ref.watch(containerSizeProvider);
        final focusIndex = ref.watch(onFocusIndexProvider);

        String id = deviceConfig['deviceID'];
        String name = deviceConfig['deviceName'];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width,
          height: containerSize,
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: $id', style: white18,),
                        Text('Имя: $name', style: const TextStyle(color: Colors.white, fontSize: 18),),
                      ],
                    ),
                  ),
          
                  const Expanded(child: SizedBox(width: 5,)),

                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: focusIndex == 1 ? Colors.white : Colors.blueGrey.shade600,
                    ),
                    child: 
                    TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onFocusChange: (bool isFocused) { 
                        isFocused ? {
                          ref.read(onFocusIndexProvider.notifier).state = 1,
                          ref.read(containerSizeProvider.notifier).state = 95,
                        } : null;
                      },
                      onPressed: () { 
                        ref.read(contentForDisplayProvider.notifier).state = [];
                        ref.read(contentIndexProvider.notifier).state = 0;
                        ref.read(containerSizeProvider.notifier).state = 0;
                        ref.read(onFocusIndexProvider.notifier).state = 999;
                        return ref.refresh(getConfigProvider); 
                      }, 
                      child: const Text('обновить')
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: focusIndex == 2 ? Colors.white : Colors.blueGrey.shade600,
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onFocusChange: (bool isFocused) { 
                        isFocused ? {
                          ref.read(onFocusIndexProvider.notifier).state = 2,
                          ref.read(containerSizeProvider.notifier).state = 95,
                        } : null;
                      },
                      onPressed: (){ 
                        ref.read(onFocusIndexProvider.notifier).state = 999;
                        ref.read(containerSizeProvider.notifier).state = 0;
                      }, 
                      child: const Text('закрыть')
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: focusIndex == 3 ? Colors.white : Colors.blueGrey.shade600,
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onFocusChange: (bool isFocused) { 
                        isFocused ? {
                          ref.read(onFocusIndexProvider.notifier).state = 3,
                        } : null;
                      },
                      onPressed: () async { 
                        ref.read(onFocusIndexProvider.notifier).state = 999;
                        ref.read(containerSizeProvider.notifier).state = 0;

                        ref.read(contentForDisplayProvider.notifier).state = [];
                        ref.read(contentIndexProvider.notifier).state = 0;
                        await ServerImpl().disconectDevice().then((value) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Auth()));
                        });
                        DeviceImpl().deleteAllContents();
                        
                      }, 
                      child: const Text('отключить')
                    ),
                  ),

                  const SizedBox(width: 10,),

                  InkWell(
                    onFocusChange: (bool isFocused){ 
                      isFocused ? {
                        ref.read(onFocusIndexProvider.notifier).state = 4,
                        ref.read(containerSizeProvider.notifier).state = 95,
                      } : null; 
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: IconButton(
                        onPressed: (){ 
                          ref.read(onFocusIndexProvider.notifier).state = 999;
                          ref.read(containerSizeProvider.notifier).state = 0;
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ContentLib(deviceConfig: deviceConfig)));
                        }, 
                        icon: const Icon(Icons.photo_library, size: 45,),
                        color: containerSize == 0 ? Colors.transparent : focusIndex == 4 ? Colors.white : Colors.blueGrey.shade600,
                        splashRadius: 1,
                      ),
                    )
                  ),

                  const SizedBox(width: 20,), 
                ],
              ),
            ),
          ),
        );
      }
    )
  );
}