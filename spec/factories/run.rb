FactoryBot.define do
  factory :run do
    node1 { 'AF-AGO' }
    node2 { 'AF-BDI' }
    capacity { 10 }
    start_year { 2020 }
    end_year { 2050 }
    resolution do
      {
        day_parts: [
          { id: 'D1', start_hour: 0, end_hour: 4 },
          { id: 'D2', start_hour: 4, end_hour: 22 },
          { id: 'D3', start_hour: 22, end_hour: 24 },
        ],
        seasons: [
          { id: 'S1', months: [1, 2, 3, 4, 5, 6] },
          { id: 'S2', months: [7, 8, 9, 10, 11, 12] },
        ],
      }
    end
    geographic_scope { %i[IND] }
  end
end
