class BuildText
  def run(publication, lang: "eng")
    Page.transaction do
      publication.pages.includes(:image).find_each do |page|
        analyze_page(page, lang)
      end
    end
  end

  def analyze_page(page, lang)
    page.text_items.destroy_all
    page.page_texts.destroy_all
    MinOpenCV.imwrite("page.jpg", page.image.data)

    tesseract_result = RTesseract.new("page.jpg", lang: lang, psm: 11)
    create_text_blocks(tesseract_result, page)
    create_text_items(tesseract_result, page)
  end

  private

  def create_text_items(tesseract_result, page)
    tesseract_result.to_box.each do |box|
      TextItem.create!(
        page: page,
        text: box[:word],
        x1: box[:x_start],
        y1: box[:y_start],
        x2: box[:x_end],
        y2: box[:y_end]
      )
    end
  end

  def create_text_blocks(tesseract_result, page)
    textblock = tesseract_result.to_s.strip
    PageText.create!(
      text: textblock,
      page: page
    )
  end
end
