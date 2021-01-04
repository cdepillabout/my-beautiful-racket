
#lang recipi

data Dim3D =
  length :: Size
  width :: Size
  height :: Size

module meat
  module pork

   import step (slice)

    loin
      i18n
        english "Pork Shoulder Loin"
        japanese "豚肩ロース"
      type Ingredient

    sliced-loin
      i18n
        english "Pork Shoulder Loin"
        japanese "豚肩ロース"
      type Dim3D -> Ingredient
      fun size = slice size loin

    thin-sliced-loin :: Ingredient
    thin-sliced-loin =
      dim = Dim3D { length = 3mm, width = 15cm, height = 7cm }
      sliced-loin

import meat.pork (thin-sliced-loin)

