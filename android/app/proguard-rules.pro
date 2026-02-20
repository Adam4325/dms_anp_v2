# ML Kit text recognition: kita hanya pakai Latin. Class Chinese/Devanagari/Japanese/Korean
# adalah modul opsional yang tidak di-include, supaya R8 tidak gagal.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
