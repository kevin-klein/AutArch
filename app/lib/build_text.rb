class BuildText
  def run
    Page.transaction do
      Page.includes(:image).find_each do |page|
        analyze_page(page)
      end
    end
  end

  def analyze_page(page)
    page.text_items.destroy_all
    page.page_texts.destroy_all
    ImageProcessing.imwrite('page.jpg', page.image.data)

    tesseract_result = RTesseract.new('page.jpg', lang: 'eng', psm: 11)
    create_text_blocks(tesseract_result)
    create_text_items(tesseract_result)
  end

  private

  def create_text_items(tesseract_result)
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

  def create_text_blocks(tesseract_result)
    textblock = tesseract_result.to_s.strip
    PageText.create!(
      text: textblock,
      page: page
    )
  end
end
