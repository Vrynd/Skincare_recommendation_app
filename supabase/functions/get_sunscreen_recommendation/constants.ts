export const similarity: Record<string, Record<string, number>> = {
  "oily": {
    "oily": 30,
    "combination": 20,
    "normal": 10,
    "dry": 5,
    "sensitive": 0
  },
  "dry": {
    "dry": 30,
    "normal": 20,
    "combination": 10,
    "oily": 5,
    "sensitive": 5
  },
  "normal": {
    "normal": 30,
    "combination": 15,
    "dry": 10,
    "oily": 10,
    "sensitive": 5
  },
  "combination": {
    "combination": 30,
    "oily": 20,
    "normal": 10,
    "dry": 5,
    "sensitive": 0
  },
  "sensitive": {
    "sensitive": 30,
    "normal": 10,
    "dry": 10,
    "oily": 0,
    "combination": 0
  }
};

export const texture_match: Record<string, Record<string, number>> = {
  "gel":    {"gel":15, "serum":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
  "cream":  {"cream":15, "lotion":10, "milk":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
  "lotion": {"lotion":15, "milk":12, "cream":8, "gel":8, "serum":8, "watery":5, "mist":3, "stick":0, "spray":0},
  "serum":  {"serum":15, "gel":10, "watery":8, "lotion":5, "milk":3, "mist":3, "cream":0, "stick":0, "spray":0},
  "milk":   {"milk":15, "lotion":12, "cream":8, "serum":5, "gel":3, "watery":3, "mist":0, "stick":0, "spray":0},
  "watery": {"watery":15, "gel":12, "serum":10, "mist":8, "lotion":5, "milk":3, "cream":0, "stick":0, "spray":0},
  "stick":  {"stick":15, "spray":10, "lotion":5, "gel":3, "serum":3, "watery":3, "cream":0, "milk":0, "mist":0},
  "spray":  {"spray":15, "stick":10, "mist":8, "lotion":5, "gel":3, "watery":3, "cream":0, "milk":0, "serum":0},
  "mist":   {"mist":15, "spray":10, "watery":8, "gel":5, "serum":5, "lotion":3, "cream":0, "milk":0, "stick":0}
};
