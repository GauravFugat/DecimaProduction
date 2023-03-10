public class RT_CSVReader implements Iterable<List<String>>, Iterator<List<String>> {
    public Integer cnt = 0;
	private final static String COMMA = ',';
	private final static String CR = '\r';
	private final static String LF = '\n';
	private final static String CRLF = '\r\n';
	private final static String QUOTE = '"';
	private final static String DOUBLE_QUOTE = '""';
	
	private String csvString;
	private Integer csvStringLength;
	private Integer position = 0;
	private Iterator<List<String>> it;
	
	public RT_CSVReader(String csvString) {
        System.debug('in RT_CSVReader');
		this.csvString = convertLineEndings(csvString.trim());
		this.csvStringLength = csvString.length();
		this.it = iterator();
	}
	
	public static List<List<String>> read(String csvString) {
        System.debug('in read');
		List<List<String>> res = new List<List<String>>();
		RT_CSVReader reader = new RT_CSVReader(csvString);
		while (reader.it.hasNext()) {
			res.add(reader.it.next());
		}
		return res;
	}
	
	private static String convertLineEndings(String str) {
		return str.replace(CRLF, LF).replace(CR, LF);
	}
	
	public Iterator<List<String>> iterator() {
		return this;
	}
	
	public Boolean hasNext() {
		return position < csvStringLength;
        //return position < 1;
	}
	
	public List<String> next() {
		List<String> values = new List<String>();
		position = readLine(position, values);
		return values;
	}
	 
	private Integer readLine(Integer position, List<String> values) {
		Integer startPos = position;
		
		String currentValue;
		Integer cAt, nlAt, foundAt;
		
		List<String> tmpValues = new List<String>();
        Integer i = 1;
        
		while (position < csvStringLength) {
            cnt++;
			//cAt = csvString.indexOf(COMMA, position);
			nlAt = csvString.indexOf(LF, position);
			//foundAt = Math.min(cAt, nlAt);
			foundAt = nlAt;
			
			if (foundAt < 0) {
				//foundAt = Math.max(cAt, nlAt);
				foundAt = nlAt;
			}
			if (foundAt < 0) {
				currentValue = csvString.substring(startPos);
				position = csvStringLength;
			}
			else {
				currentValue = csvString.substring(startPos, foundAt);
				position = foundAt + 1;
			}
			
			if (!currentValue.startsWith(QUOTE)) {
				tmpValues.add(currentValue);
				
				if (foundAt == nlAt) {
					break;
				}
				startPos = position;
			}
			else if (currentValue == DOUBLE_QUOTE) {
				tmpValues.add('');
				if (foundAt == nlAt) {
					break;
				}
				startPos = position;
			}
			else if (currentValue.endsWith(QUOTE)) {
				Integer lastIndex = currentValue.length() - 1;
				tmpValues.add(currentValue.substring(1, lastIndex));
				if (foundAt == nlAt) {
					break;
				}
				startPos = position;
			}
            i++; 
		}
		values.addAll(tmpValues); 
		return position; 
	} 
}