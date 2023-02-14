namespace :cleanup do
  task skeletons: :environment do
    contained_skeletons = []

    Grave.transaction do
      Grave.includes(skeletons: :figure).find_each do |grave|
        skeletons = grave.skeletons.to_a

        skeletons.each do |skeleton1|
          skeletons.each do |skeleton2|
            if skeleton1.id != skeleton2.id && skeleton1.figure.contains?(skeleton2.figure)
              contained_skeletons << skeleton2
            end
          end
        end
      end

      contained_skeletons.uniq.each do |skeleton|
        skeleton.figure.destroy
      end
    end
  end
end
