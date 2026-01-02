# Human Action Required

## Data Source Contacts

- [ ] **Contact SemanticHadith team** - Request data access
  - Email: <amna.kamran@nu.edu.pk> or <amna.basharat@nu.edu.pk>
  - GitHub: <https://github.com/A-Kamran/SemanticHadithKG>
  - Ask for: RDF dump access, Figshare link fix
  
- [ ] **Research OntoDIN** - Islamic ontology dataset
  - Find contact info and data availability
  - Potential for narrator/isnad enrichment

## API Keys Needed

- [ ] **Sunnah.com API key** - For official hadith data
  - Request via GitHub issue at sunnah.com repo

## Graph Integrity

- [ ] **22 orphan verses** - Verses with no root word links
  - Run `python3 almizan-etl/verify_graph_integrity.py` to see details
  - May need morphology data enrichment or manual review
