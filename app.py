from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('user_sign_up.html')


@app.route('/account')
def account():
    return render_template('account.html')


def main():
    app.run(debug=True)


if __name__ == "__main__":
    main()
