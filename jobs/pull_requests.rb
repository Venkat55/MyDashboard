require 'octokit'
SCHEDULER.every '10s', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => "f370f5d6ec8a14e5b1ac19d65773bcd34c54714f")
  my_organization = "Qwinix"
  repo_name = []
  client.organization_repositories(my_organization).map do |repo| 
    repo_name << repo.name if repo.name == 'loan_list'
  end

  open_pull_requests = repo_name.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'open').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
        creator: "@" + pull.user.login,
        })
    end
    pulls
  }
  send_event('openPrs', { header: "Open Pull Requests", pulls: open_pull_requests })
end