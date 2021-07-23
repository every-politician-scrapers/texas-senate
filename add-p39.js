module.exports = (id) => {
  qualifiers = {
    P2937: 'Q104767030', // 87th Legislature
  }

  return {
    id,
    claims: {
      P39: {
        value: 'Q18565274', // Texas State Senator
        qualifiers: qualifiers,
        references: {
          P854: 'https://senate.texas.gov/members.php',
          P1476: {
            text: 'Texas Senators of the 87th Legislature',
            language: 'en',
          },
          P813: new Date().toISOString().split('T')[0],
          P407: 'Q1860', // language: English
        }
      }
    }
  }
}
