
library("htmltools")
library("bsplus")


carousel <- 
  bs_carousel(id = "the_images", use_indicators = TRUE) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/1.jpg"),
    caption = bs_carousel_caption("","Seedlings germination")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/2.jpg"),
    caption = bs_carousel_caption("","Germination in nursery")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/3.jpg"),
    caption = bs_carousel_caption("","Yam plants in the field")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/4.jpg"),
    caption = bs_carousel_caption("","Tuber storage")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/5.jpg"),
    caption = bs_carousel_caption("","Tuber storage")
  ) %>%
  bs_append(
    content = bs_carousel_image(src = "images/yam/6.jpg"),
    caption = bs_carousel_caption("","Sprouting tubers")
  ) 