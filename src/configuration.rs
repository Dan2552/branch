pub struct Configuration { 
    pub is_verbose: bool, 
    pub prefer_local: bool,
    pub prefer_remote: bool,
    pub prefer_discard: bool,
    pub prefer_keep: bool,
    pub list: bool,
    pub choice: bool,
    pub target_branch: String
}