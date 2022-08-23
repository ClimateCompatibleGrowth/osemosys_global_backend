FactoryBot.define do
  factory :parameter_row do
    id { 0 }
    type { 'interconnector' }
    interconnector_nodes { %w[AF-AGO-XX AF-COD-XX] }
    capacity { 1 }
    start_year { 2020 }
    end_year { 2050 }
  end
end
