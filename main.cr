require "csv"
require "kemal"

csv = CSV.new File.read("bp.csv"), headers: true
rows = [] of Hash(String, String)
while csv.next
    rows << csv.row.to_h
end

get "/" do |env|
    states = rows.map &.["State"]
    render "public/index.ecr"
end

post "/" do |env|
    state = env.params.body["state"].as String
    env.redirect "/state/#{state}"
end

get "/state/:state" do |env|
    row = rows.reject(&.["State"].!=(env.params.url["state"].gsub("%20", " ")))
    if row.size == 0
        env.redirect "/"
        next
    end
    row = row[0]
    if row["AllMail"] == "true"
        render "public/allmail.ecr"
    else
        render "public/countdown.ecr"
    end
end

Kemal.run