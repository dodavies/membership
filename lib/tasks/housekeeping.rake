# frozen_string_literal: true

namespace :membership do
  namespace :housekeeping do

    desc "Generate member CRSids from primary email addresses"
    task generate_crsids: :environment do
      Member.where(crsid: nil).where("primary_email LIKE '%cam.ac.uk'").find_each do |member|
        parts = member.primary_email.split("@")
        begin
          if parts.length == 2 && parts[1] == "cam.ac.uk"
            member.crsid = parts[0]
            member.save(validate: false)
          end
        rescue => e
          puts "Member #{member.id}: #{e}"
        end
      end
    end

    desc "Mark graduating ordinary members as associate members"
    task process_graduates: :environment do
      type_ord = Type.find_by(name: "Ordinary")
      type_asc = Type.find_by(name: "Associate")
      Member.where(type: type_ord).where("graduation_year <= ?", Date.today.year).find_each do |member|
        member.type = type_asc
        member.save(validate: false)
      end
    end

  end
end