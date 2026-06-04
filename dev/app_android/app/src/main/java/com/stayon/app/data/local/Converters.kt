package com.stayon.app.data.local

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class Converters {
    private val gson = Gson()

    @TypeConverter
    fun fromStringList(value: List<String>): String = gson.toJson(value)

    @TypeConverter
    fun toStringList(value: String): List<String> {
        return try {
            val type = object : TypeToken<List<String>>() {}.type
            gson.fromJson(value, type)
        } catch (_: Exception) {
            emptyList()
        }
    }

    @TypeConverter
    fun fromIntList(value: List<Int>): String = gson.toJson(value)

    @TypeConverter
    fun toIntList(value: String): List<Int> {
        return try {
            val type = object : TypeToken<List<Int>>() {}.type
            gson.fromJson(value, type)
        } catch (_: Exception) {
            emptyList()
        }
    }

    @TypeConverter
    fun fromLongList(value: List<Long>): String = gson.toJson(value)

    @TypeConverter
    fun toLongList(value: String): List<Long> {
        return try {
            val type = object : TypeToken<List<Long>>() {}.type
            gson.fromJson(value, type)
        } catch (_: Exception) {
            emptyList()
        }
    }
}
